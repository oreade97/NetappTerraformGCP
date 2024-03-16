//PROJECT VARIABLES

variable "project_id" {
  description = "The ID of the GCP project"
}

variable "gcp_service_list" {
  type        = list(string)
  description = "The list of apis needed"
  default     = []
}

variable "gcpregion" {
  description = "The REGION of the GCP project"
}

variable "service_account_key_file" {
  description = "The path to the service account key file"
}

//BUCKET VARIABLES

variable "account_id" {
  description = "Service Account ID"
}

variable "display_name" {
  description = "The bucket display name"

}

variable "bucket_name" {
  description = "The name of the storage bucket"
}

variable "bucket_location" {
  description = "The location for the storage bucket"

}

variable "key_ring_name" {
  description = "The CMEK key ring name"
}

variable "crypto_key_name" {
  description = "The CMEK key name"
}

variable "functionname" {
  description = "The function name"

}