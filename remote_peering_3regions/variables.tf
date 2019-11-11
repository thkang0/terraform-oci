# Required by the OCI Provider
variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}

variable "seoul_region" {
  default = "ap-seoul-1"
}

variable "phx_region" {
  default = "us-phoenix-1"
}

variable "london_region" {
  default = "uk-london-1"
}


# Network
variable "seoul_vcn_cidr" {
    default = "10.0.0.0/20"
}

variable "public_subnet1_seoul_cidr" {
    default = "10.0.0.0/24"
}

variable "phx_vcn_cidr" {
    default = "10.0.16.0/20"
}

variable "public_subnet1_phx_cidr" {
    default = "10.0.16.0/24"
}

variable "london_vcn_cidr" {
    default = "10.0.32.0/20"
}

variable "public_subnet1_london_cidr" {
    default = "10.0.32.0/24"
}


