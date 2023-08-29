# Configure the GCP and NetApp Cloud Manager providers

terraform {
  required_providers {
    netapp-cloudmanager = {
      source = "NetApp/netapp-cloudmanager"
      version = "23.1.1"
    }
    google = {
      source = "hashicorp/google"
      version = "4.68.0"
    }
  }
}

provider "netapp-cloudmanager" {
  refresh_token = var.refresh_token
}

provider "google" {
  project     = var.gcp_project
  region      = var.gcp_region
  credentials = var.gcp_credentials

}


# Create the custom role for the user that deploys TF

  resource "google_project_iam_custom_role" "Cloud_Central_role" {
  role_id   = "CM_Connector_Setup"
  title     = "CVO User Role"
  stage     = "GA"
  description = "Permissions for the user who deploys Cloud Manager from NetApp Cloud Central"
  permissions = [
      "compute.disks.create",
      "compute.disks.get",
      "compute.disks.list",
      "compute.disks.setLabels",
      "compute.disks.use",
      "compute.firewalls.create",
      "compute.firewalls.delete",
      "compute.firewalls.get",
      "compute.firewalls.list",
      "compute.globalOperations.get",
      "compute.images.get",
      "compute.images.getFromFamily",
      "compute.images.list",
      "compute.images.useReadOnly",
      "compute.instances.attachDisk",
      "compute.instances.create",
      "compute.instances.get",
      "compute.instances.list",
      "compute.instances.setDeletionProtection",
      "compute.instances.setLabels",
      "compute.instances.setMachineType",
      "compute.instances.setMetadata",
      "compute.instances.setServiceAccount",
      "compute.instances.setTags",
      "compute.instances.start",
      "compute.instances.updateDisplayDevice",
      "compute.machineTypes.get",
      "compute.networks.get",
      "compute.networks.list",
      "compute.projects.get",
      "compute.regions.get",
      "compute.regions.list",
      "compute.subnetworks.get",
      "compute.subnetworks.list",
      "compute.zoneOperations.get",
      "compute.zones.get",
      "compute.zones.list",
      "deploymentmanager.compositeTypes.get",
      "deploymentmanager.compositeTypes.list",
      "deploymentmanager.deployments.create",
      "deploymentmanager.deployments.delete",
      "deploymentmanager.deployments.get",
      "deploymentmanager.deployments.list",
      "deploymentmanager.manifests.get",
      "deploymentmanager.manifests.list",
      "deploymentmanager.operations.get",
      "deploymentmanager.operations.list",
      "deploymentmanager.resources.get",
      "deploymentmanager.resources.list",
      "deploymentmanager.typeProviders.get",
      "deploymentmanager.typeProviders.list",
      "deploymentmanager.types.get",
      "deploymentmanager.types.list",
      "iam.serviceAccounts.list",
      "resourcemanager.projects.get"
  ]
}

# Bind the Role to the current logged in user

  resource "google_project_iam_member" "custom_role_binding" {
  project = var.gcp_project
  role    = "projects/${var.gcp_project}/roles/CM_Connector_Setup"
  member  = "user:${var.user_email}"
}


# Create the custom role for the Connector SA

    resource "google_project_iam_custom_role" "Connector_role" {
  role_id   = "CM_Connector"
  title     = "NetApp Connector"
  stage     = "GA"
  description = "Permissions for the service account associated with the Connector instance."
  permissions = [
    "bigquery.datasets.create",
    "bigquery.datasets.get",
    "bigquery.jobs.create",
    "bigquery.jobs.get",
    "bigquery.jobs.list",
    "bigquery.jobs.listAll",
    "bigquery.tables.create",
    "bigquery.tables.get",
    "bigquery.tables.getData",
    "bigquery.tables.list",
    "cloudkms.cryptoKeyVersions.useToEncrypt",
    "cloudkms.cryptoKeys.get",
    "cloudkms.cryptoKeys.list",
    "cloudkms.keyRings.list",
    "compute.addresses.get",
    "compute.addresses.list",
    "compute.backendServices.create",
    "compute.disks.create",
    "compute.disks.createSnapshot",
    "compute.disks.delete",
    "compute.disks.get",
    "compute.disks.list",
    "compute.disks.setLabels",
    "compute.disks.use",
    "compute.firewalls.create",
    "compute.firewalls.delete",
    "compute.firewalls.get",
    "compute.firewalls.list",
    "compute.globalOperations.get",
    "compute.images.get",
    "compute.images.getFromFamily",
    "compute.images.list",
    "compute.images.useReadOnly",
    "compute.instanceGroups.get",
    "compute.instances.addAccessConfig",
    "compute.instances.attachDisk",
    "compute.instances.create",
    "compute.instances.delete",
    "compute.instances.detachDisk",
    "compute.instances.get",
    "compute.instances.getSerialPortOutput",
    "compute.instances.list",
    "compute.instances.setDeletionProtection",
    "compute.instances.setLabels",
    "compute.instances.setMachineType",
    "compute.instances.setMetadata",
    "compute.instances.setServiceAccount",
    "compute.instances.setTags",
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.updateDisplayDevice",
    "compute.instances.updateNetworkInterface",
    "compute.machineTypes.get",
    "compute.networks.get",
    "compute.networks.list",
    "compute.networks.updatePolicy",
    "compute.projects.get",
    "compute.regionBackendServices.create",
    "compute.regionBackendServices.get",
    "compute.regionBackendServices.list",
    "compute.regions.get",
    "compute.regions.list",
    "compute.snapshots.create",
    "compute.snapshots.delete",
    "compute.snapshots.get",
    "compute.snapshots.list",
    "compute.snapshots.setLabels",
    "compute.subnetworks.get",
    "compute.subnetworks.list",
    "compute.subnetworks.use",
    "compute.subnetworks.useExternalIp",
    "compute.zoneOperations.get",
    "compute.zones.get",
    "compute.zones.list",
    "deploymentmanager.compositeTypes.get",
    "deploymentmanager.compositeTypes.list",
    "deploymentmanager.deployments.create",
    "deploymentmanager.deployments.delete",
    "deploymentmanager.deployments.get",
    "deploymentmanager.deployments.list",
    "deploymentmanager.manifests.get",
    "deploymentmanager.manifests.list",
    "deploymentmanager.operations.get",
    "deploymentmanager.operations.list",
    "deploymentmanager.resources.get",
    "deploymentmanager.resources.list",
    "deploymentmanager.typeProviders.get",
    "deploymentmanager.typeProviders.list",
    "deploymentmanager.types.get",
    "deploymentmanager.types.list",
    "iam.serviceAccounts.actAs",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.list",
    "logging.logEntries.list",
    "logging.privateLogEntries.list",
    "monitoring.timeSeries.list",
    "resourcemanager.projects.get",
    "storage.buckets.create",
    "storage.buckets.delete",
    "storage.buckets.get",
    "storage.buckets.getIamPolicy",
    "storage.buckets.list",
    "storage.buckets.update",
    "storage.objects.get",
    "storage.objects.list"

  ]
}



#Create Service Account for the Connector

resource "google_service_account" "netapp_connector" {
  account_id   = "netapp-connector"
  display_name = "NetApp Connector"
  description  = "Service account associated with the NetApp Cloud Manager Connector"
  project      = var.gcp_project
}


# Bind Role to Connector SA

resource "google_project_iam_member" "service_account_role_binding" {
  project = var.gcp_project
  role    = "projects/${var.gcp_project}/roles/CM_Connector"
  member  = "serviceAccount:${google_service_account.netapp_connector.email}"
}



#Create Service Account for Tiering

resource "google_service_account" "cvo_tiering" {
  account_id   = "cvo-tiering"
  display_name = "NetApp CVO Tiering"
  description  = "Service account associated with the NetApp Cloud Volumes ONTAP instances"
  project      = var.gcp_project
}


# Bind Storage Admin Role to Tiering SA

resource "google_project_iam_member" "service_account_role_binding_tiering" {
  project = var.gcp_project
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.cvo_tiering.email}"
}


# Assign connector SA as a user on the Tiering SA

resource "google_service_account_iam_binding" "tiering_user" {
  service_account_id = google_service_account.cvo_tiering.name
  role               = "roles/iam.serviceAccountUser"
  members  =[ "serviceAccount:${google_service_account.netapp_connector.email}" ]
}



#Create the connector

resource "netapp-cloudmanager_connector_gcp" "demo-connector" {
  name = var.gcp_connector_name 
  zone = var.gcp_connector_zone
  company = var.gcp_connector_company
  project_id = var.gcp_project
  service_account_email = google_service_account.netapp_connector.email
  service_account_path = var.gcp_connector_service_account_path
  associate_public_ip = true
  account_id = var.account_id
}

#Create vpc and  subnets for CVO HA 

resource "google_compute_network" "vpc_network_cluster" {
  name = "clustervpc"
}

resource "google_compute_subnetwork" "subnet1_cluster_connectivity" {
  name          = "my-subnet-cluster"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-east4"
  network       = google_compute_network.vpc_network_cluster.self_link
}

resource "google_compute_network" "vpc_network_ha" {
  name = "havpc"
}

resource "google_compute_subnetwork" "subnet2_ha_connectivity" {
  name          = "my-subnet-ha"
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-east4"
  network       = google_compute_network.vpc_network_ha.self_link
}

resource "google_compute_network" "vpc_network_mediator" {
  name = "mediatorvpc"
}

resource "google_compute_subnetwork" "subnet3_data_replication" {
  name          = "my-subnet-mediator"
  ip_cidr_range = "10.0.3.0/24"
  region        = "us-east4"
  network       = google_compute_network.vpc_network_mediator.self_link
}

# Create NetApp CVO HA; NB: the variables here can be defined and given values in the variables.tf and terraform.tfvars file respectively;

   resource "netapp-cloudmanager_cvo_gcp" "cl-cvo-gcp-ha" {
       provider = netapp-cloudmanager
       capacity_package_name = "Professional"
       capacity_tier         = "cloudStorage"
       client_id             = netapp-cloudmanager_connector_gcp.demo-connector.client_id
       data_encryption_type  = "GCP"
       gcp_service_account   = google_service_account.cvo_tiering.email
       gcp_volume_size       = 1
       gcp_volume_size_unit  = "TB"
       gcp_volume_type       = "pd-ssd"
       #id                   = (known after apply)
       instance_type         = "n1-standard-8"
       is_ha                 = true
       license_type          = "ha-capacity-paygo"
       name                  = "tfcvohahigh"
       ontap_version         = "latest"
       project_id            = var.gcp_cvo_project_id
       #subnet_id            = "vpc-subnet"
       #svm_name             = (known after apply)
       svm_password          = "xxxxxxxx"
       tier_level            = "standard"
       upgrade_ontap_version = false
       use_latest_version    = true
       vpc_id                = "default"
       workspace_id          = "xxxxx"
       zone                  = "us-east4-b"
       node1_zone			       = "us-east4-b"
       node2_zone			       = "us-east4-c"
       mediator_zone		     = "us-east4-a"
       vpc0_node_and_data_connectivity = "projects/${var.gcp_project}/global/networks/default" 
       vpc1_cluster_connectivity = google_compute_network.vpc_network_cluster.name
       vpc2_ha_connectivity = google_compute_network.vpc_network_ha.name
       vpc3_data_replication = google_compute_network.vpc_network_mediator.name
       subnet0_node_and_data_connectivity = "projects/${var.gcp_project}/regions/us-east4/subnetworks/default"
       subnet1_cluster_connectivity = google_compute_subnetwork.subnet1_cluster_connectivity.name
       subnet2_ha_connectivity = google_compute_subnetwork.subnet2_ha_connectivity.name
       subnet3_data_replication = google_compute_subnetwork.subnet3_data_replication.name
                   
    }

    