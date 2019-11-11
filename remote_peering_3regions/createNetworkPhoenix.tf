provider "oci" {
  version = ">= 3.0.0"
  alias            = "phoenix"
  tenancy_ocid     = "${var.tenancy_ocid}"
  region           = "${var.phx_region}"
}

resource "oci_core_virtual_network" "test_phx_vcn" {
    provider       = "oci.phoenix"
    cidr_block     = "${var.phx_vcn_cidr}"
    #compartment_id = "${oci_identity_compartment.test_compartment.id}"
    compartment_id = "${var.compartment_ocid}"
    display_name   = "test_phx_vcn"
    dns_label      = "phxvcn"
}

resource "oci_core_internet_gateway" "test_phxvcn_ig" {
    provider       = "oci.phoenix"
    compartment_id = "${var.compartment_ocid}"
    display_name   = "test_phxvcn_ig"
    vcn_id         = "${oci_core_virtual_network.test_phx_vcn.id}"
}

# Create DRG
resource "oci_core_drg" "test_phxvcn_drg" {
    provider       = "oci.phoenix"
    compartment_id = "${var.compartment_ocid}"
    display_name   = "test_phxvcn_drg"
    freeform_tags = {"Test"= "RemotePeering"}
}

resource "oci_core_drg_attachment" "test_phxvcn_drg_attachment" {
    provider       = "oci.phoenix"
    drg_id   = "${oci_core_drg.test_phxvcn_drg.id}"
    vcn_id         = "${oci_core_virtual_network.test_phx_vcn.id}"
}

resource "oci_core_remote_peering_connection" "test_phxvcn_drg_remote_peering_connection1" {
    provider       = "oci.phoenix"
    compartment_id = "${var.compartment_ocid}"
    drg_id   = "${oci_core_drg.test_phxvcn_drg.id}"
    display_name     = "remotePeeringConnection1_phx_phx"
    #vcn_id         = "${oci_core_virtual_network.test_phx_vcn.id}"
}

resource "oci_core_route_table" "test_phx_vcn_route_table" {
    provider       = "oci.phoenix"
    compartment_id = "${var.compartment_ocid}"
    vcn_id         = "${oci_core_virtual_network.test_phx_vcn.id}"
    display_name   = "phxvcn_route_table"
    route_rules {
        destination       = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
        network_entity_id = "${oci_core_internet_gateway.test_phxvcn_ig.id}"
    }
    route_rules {
        destination       = "${var.seoul_vcn_cidr}"
        destination_type  = "CIDR_BLOCK"
        network_entity_id = "${oci_core_drg.test_phxvcn_drg.id}"
    }
}

resource "oci_core_security_list" "public_subnet_phxvcn" {
    provider       = "oci.phoenix"

    compartment_id = "${var.compartment_ocid}"
    display_name   = "public_all"
    vcn_id         = "${oci_core_virtual_network.test_phx_vcn.id}"

    egress_security_rules {
        destination = "0.0.0.0/0"
        protocol = "all"
    }

    ingress_security_rules {
        tcp_options {
            max = 80
            min = 80
        }
        protocol = "6"
        source = "0.0.0.0/0"
    }
    ingress_security_rules {
        tcp_options {
            max = 22
            min = 22
        }
        protocol = "6"
        source = "0.0.0.0/0"
    }

    ingress_security_rules {
        tcp_options {
            max = 1521
            min = 1521
        }
        protocol = "6"
        source = "10.0.0.0/16"
    }
}

# create subnet
resource "oci_core_subnet" "public_subnet1_phxvcn" {
  provider            = "oci.phoenix"
  cidr_block          = "${var.public_subnet1_phx_cidr}"
  display_name        = "public_subnet1_phxvcn"
  dhcp_options_id     = "${oci_core_virtual_network.test_phx_vcn.default_dhcp_options_id}"
  dns_label           = "pub1"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.test_phx_vcn.id}"
  route_table_id      = "${oci_core_route_table.test_phx_vcn_route_table.id}"
  security_list_ids   = ["${oci_core_security_list.public_subnet_phxvcn.id}"]
  # prohibit_public_ip_on_vnic is true for private subnet
  prohibit_public_ip_on_vnic = false
}



