variable "gcp_project" {
  type        = string
  description = "Project Number."
  default     = null
}

variable "gcp_service_account" {
  type        = string
  description = "/Users/oreoluwaadesina/Documents/Terraform/Dual_Protocol/terraform-example/gcloud-compute-engine-vm/gcpkey.json"
  default     = null
}

variable "network" {
  description = "Network to deploy to. Only one of network or subnetwork should be specified."
  default     = ""
}

variable "region" {
  type        = string
  description = "Region where the instances should be created."
  default     = null
}

variable "volume_name" {
  type        = string
  description = "Name of CVS volume."
  default     = null
}


variable "project_number" {
  type        = string
  description = "Project Number"
  default     = null
}



variable "protocol" {
  type        = list(string)
  description = "Enabled NAS protocols NFSv3, NFSv4, CIFS, SMB."
  default     = ["NFSv3"]
}

variable "size" {
  type        = number
  description = "Size of volume in GB"
  default     = 1024
}

variable "service_level" {
  type        = string
  description = "Service level standard, premium or extreme."
  default     = "premium"
}

variable "storage_class" {
  type        = string
  description = "Type of CVS service: CVS=software, CVS-Performance=hardware."
  default     = "hardware"
}

variable "zone" {
  type        = string
  description = "GCP zone CVS-Software is deployed to. Required for CVS-Software."
  default     = null
}


