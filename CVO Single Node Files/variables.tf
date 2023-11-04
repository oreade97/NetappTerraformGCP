variable "gcp_credentials" {
  type = string
  sensitive = true
  description = "Google Cloud service account credentials"
}

variable "user_email" {
  description = "user id for deployment"
}

variable "gcp_region" {
  description = "Project ID for deployment"
}

variable "refresh_token" {
  description = "The refresh token from NetApp cloud manager."
}

variable "gcp_connector_deploy_bool" {
  description = "Do you want to create a new GCP Connector?"
  type        = bool
}
variable "gcp_connector_company" {
  description = "Name of the org"
}

variable "gcp_connector_name" {
  description = "Name of the GCP Connector"
}

variable "gcp_project" {
  description = "Project ID for deployment"
}

variable "gcp_connector_zone" {
  description = "Zone for GCP Connector"
}

variable "gcp_connector_service_account_email" {
  description = "Service Account E-Mail"
}

variable "gcp_connector_service_account_path" {
  description = "Path to the JSON GCP Key"
}


variable "gcp_cvo_name" {
  description = "Name of the CVO Instance"
}

variable "gcp_cvo_project_id" {
    description = "Project ID for GCP CVO deployment"
}

variable "gcp_cvo_zone" {
  description = "Zone for NetApp CVO"
}

variable "gcp_cvo_gcp_service_account" {
  description = "Service Account E-Mail"
}

variable "gcp_cvo_svm_password" {
  description = "CVO SVM Password"
}

variable "gcp_cvo_capacity_package_name" {
  description = "CVO package type"
}

variable "gcp_cvo_license_type" {
  description= "CVO license type"
}
