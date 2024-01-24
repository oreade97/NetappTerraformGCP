

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.12.0"
    }
  }
}

provider "google" {
  credentials = file("gcpkey.json")
  project     = var.gcp_project
  #region      = var.network # Change to your desired region
}


#CREATE GCNV VPC
resource "google_compute_network" "gcnv_vpc" {
  project                 = var.gcp_project
  name                    = var.network
  auto_create_subnetworks = true #or set to false and specify subnets
}


#Peering Connection to GCNV 

### Create Private Service Access:
resource "google_project_service" "service_networking" {
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
  project            = var.gcp_project
}

### Reserve IP Range:
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "gcnv-peering-iprange"
  project       = var.gcp_project
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  //address = "selected ip range" if this is not provided GCP will automatically select an ip range to reserve
  network = var.network
}

########### Create a VPC Peering Connection:
resource "google_service_networking_connection" "private_access_connection" {
  network                 = var.network
  service                 = "netapp.servicenetworking.goog"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
  depends_on = [
    google_project_service.service_networking,
    
  ]
}


resource "google_netapp_storage_pool" "test_pool" {
  name = "test-pool"
  capacity_gib = "15360"
  location = "us-east4"
  service_level = "EXTREME"
  network = google_compute_network.gcnv_vpc.id
}
