

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.13.0"
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
  depends_on              = [google_compute_global_address.private_ip_alloc]
  network                 = var.network
  service                 = "netapp.servicenetworking.goog"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]

}


resource "google_netapp_storage_pool" "test_pool" {
  depends_on    = [google_service_networking_connection.private_access_connection]
  name          = "test-pool"
  capacity_gib  = "15360"
  location      = "us-east4"
  service_level = "EXTREME"
  network       = google_compute_network.gcnv_vpc.id
}


resource "google_netapp_volume" "test_volume" {
  depends_on   = [google_netapp_storage_pool.test_pool]
  location     = "us-east4"
  name         = "test-volume"
  capacity_gib = "100"
  share_name   = "test-volume"
  storage_pool = "test-pool"
  protocols    = ["NFSV3"]
  snapshot_policy {
    enabled = true
    daily_schedule {
      snapshots_to_keep = 7
      hour              = 10
      minute            = 1
    }
  }
  export_policy {
    rules {
      allowed_clients = "0.0.0.0/0"
      access_type     = "READ_WRITE"
      nfsv3           = true
      nfsv4           = false
    }
  }
}
