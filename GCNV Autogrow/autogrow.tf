//-----START HERE------//
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.9.0"
    }
  }
}

provider "google" {
  credentials = file(var.service_account_key_file)
  project     = var.project_id
  region      = var.gcpregion

}


//-----Service account creation------//

#Create Service Account for the autogrow
resource "google_service_account" "autogrow" {
  account_id   = var.account_id
  display_name = var.display_name
  description  = "Service account associated with autogrow"
  project      = var.project_id

  depends_on = [
    google_project_service.enabled_apis,
  ]
}

# Bind Role to SA
resource "google_project_iam_member" "service_account_role_binding" {
  project = var.project_id
  role    = "roles/netapp.admin"
  member  = "serviceAccount:${google_service_account.autogrow.email}"
}

#Creating the pubsub topic to trigger the function
resource "google_pubsub_topic" "GCNVCapacityManagerEvents" {
  name = "GCNVCapacityManagerEvents"
}

#Creating the bucket to hold the function
resource "google_storage_bucket" "function_bucket" {
  name     = var.bucket_name
  location = var.gcpregion
}

#Adding the function file to the bucket
resource "google_storage_bucket_object" "function_zip" {
  name   = var.functionname
  bucket = google_storage_bucket.function_bucket.name
  source = "autogrow.zip"
}

#Creating the function for autogrow
resource "google_cloudfunctions_function" "function" {
  depends_on            = [google_project_service.enabled_apis]
  name                  = var.functionname
  runtime               = "python39"
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_zip.name
  entry_point           = "netapp_volumes_autogrow"

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.GCNVCapacityManagerEvents.name
  }

  available_memory_mb = 256
  timeout             = 300
}

# IAM entry for the autogrow service account to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_id
  region         = var.gcpregion
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.autogrow.email}"
}

# Fetch project number
data "google_project" "project" {
}

# Monitoring Service Account is created after first Alerting Policy is created
# Creation is eventually consistent, so we wait some time for Google to create it
resource "time_sleep" "wait_30_seconds" {
  depends_on = [google_monitoring_alert_policy.alert_policy]

  create_duration = "30s"
}

# Grant "Monitoring Notification Service Agent" permissions to publish to PubSub topic
resource "google_pubsub_topic_iam_binding" "MNSA_binding" {
  project = google_pubsub_topic.GCNVCapacityManagerEvents.project
  topic   = google_pubsub_topic.GCNVCapacityManagerEvents.name
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:service-${data.google_project.project.number}@gcp-sa-monitoring-notification.iam.gserviceaccount.com"]

  depends_on = [time_sleep.wait_30_seconds]
}

# Create Cloud Monitoring notification channel
resource "google_monitoring_notification_channel" "cvs-channel" {
  display_name = "GCNV SpaceRunningLow Alerts"
  type         = "pubsub"
  labels = {
    topic = google_pubsub_topic.GCNVCapacityManagerEvents.id
  }
}

# Create CVS Alert policy
resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "GCNV-SpaceRunningLow"
  combiner     = "OR"

  # TODO: Set threshold here on line 147 (default = 80%)
  # change "val() > 0.8" to match your preferred threshold (0 = 0%, 0.8 = 80%, 1 = 100%)

  conditions {
    display_name = "Volume usage threshold"
    condition_monitoring_query_language {
      query    = <<EOF
    fetch netapp.googleapis.com/Volume
  | { t_0:
      metric 'netapp.googleapis.com/volume/bytes_used'
      | group_by 1m, [value_bytes_used_mean: mean(value.bytes_used) * 100]
  ; t_1:
      metric 'netapp.googleapis.com/volume/allocated_bytes'
      | group_by 1m, [value_allocated_bytes_mean: mean(value.allocated_bytes)] }
  | ratio
  | every 1m
  | condition gt(ratio, 10 '1')

EOF
      duration = "0s"
    }
  }

  # Whom to notify
  # See https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_notification_channel
  # and https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/monitoring_notification_channel
  notification_channels = [google_monitoring_notification_channel.cvs-channel.name]
  documentation {
    content = "Usage of GCNV volume exceeded threshold."
  }
}