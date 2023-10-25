provider "google" {
  credentials = file("gcpkey.json")
  project     = "project"
  region      = "region" # Change to your desired region
}
terraform {
  required_providers {
    netapp-gcp = {
      source  = "NetApp/netapp-gcp"
      version = "22.12.0"
    }
  }
}

provider "netapp-gcp" {
  project         = var.gcp_project
  service_account = var.gcp_service_account
}

#CREATE CVS VPC
resource "google_compute_network" "cvs_vpc" {
  project                 = var.gcp_project
  name                    = var.network
  auto_create_subnetworks = true #or set to false and specify subnets
}

#Peering Connection to CVS 
########## Create Private Service Access:
resource "google_project_service" "service_networking" {
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
  project            = var.gcp_project
}

resource "google_compute_global_address" "private_ip_alloc" {
  name          = "cvs-peering-iprange"
  project       = var.gcp_project
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  //address = "selected ip range" if this is not provided GCP will automatically select an ip range to reserve
  network = google_compute_network.cvs_vpc.id
}

########### Create a VPC Peering Connection:
resource "google_service_networking_connection" "private_access_connection" {
  network                 = google_compute_network.cvs_vpc.id
  service                 = "cloudvolumesgcp-api-network.netapp.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
  depends_on = [
    google_project_service.service_networking,
    google_compute_network.cvs_vpc
  ]
}


resource "netapp-gcp_volume" "gcp-volume" {
  provider       = netapp-gcp
  name           = var.volume_name
  region         = var.region
  protocol_types = var.protocol
  network        = var.network
  size           = var.size


}

#Add more parameters as needed according to examples on github, this is a simple script to go from no CVS to a nfs cvs volume. The CVS API has to be enabled as well.
