
provider "oci" {
  version = ">= 3.0.0"
  alias            = "london"
  tenancy_ocid     = "${var.tenancy_ocid}"
  region           = "${var.london_region}"
}

resource "oci_core_virtual_network" "test_london_vcn" {
    provider       = "oci.london"
    cidr_block     = "${var.london_vcn_cidr}"
    compartment_id = "${var.compartment_ocid}"
    display_name   = "test_london_vcn"
    dns_label      = "londonvcn"
}

resource "oci_core_internet_gateway" "test_londonvcn_ig" {
    provider       = "oci.london"
    compartment_id = "${var.compartment_ocid}"
    display_name   = "test_londonvcn_ig"
    vcn_id         = "${oci_core_virtual_network.test_london_vcn.id}"
}

# Create DRG
resource "oci_core_drg" "test_londonvcn_drg" {
    provider       = "oci.london"
    compartment_id = "${var.compartment_ocid}"
    display_name   = "test_londonvcn_drg"
    freeform_tags = {"Test"= "RemotePeering"}
}

resource "oci_core_drg_attachment" "test_londonvcn_drg_attachment" {
    provider       = "oci.london"
    drg_id   = "${oci_core_drg.test_londonvcn_drg.id}"
    vcn_id         = "${oci_core_virtual_network.test_london_vcn.id}"
}

resource "oci_core_remote_peering_connection" "test_londonvcn_drg_remote_peering_connection1" {
    provider       = "oci.london"
    #compartment_id = "${oci_identity_compartment.test_compartment.id}"
    compartment_id = "${var.compartment_ocid}"
    drg_id   = "${oci_core_drg.test_londonvcn_drg.id}"
    display_name     = "remotePeeringConnection1_london_london"
    #vcn_id         = "${oci_core_virtual_network.test_london_vcn.id}"
}




resource "oci_core_route_table" "test_london_vcn_route_table" {
    provider       = "oci.london"
    compartment_id = "${var.compartment_ocid}"
    vcn_id         = "${oci_core_virtual_network.test_london_vcn.id}"
    display_name   = "londonvcn_route_table"
    route_rules {
        destination       = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
        network_entity_id = "${oci_core_internet_gateway.test_londonvcn_ig.id}"
    }
    route_rules {
        destination       = "${var.seoul_vcn_cidr}"
        destination_type  = "CIDR_BLOCK"
        network_entity_id = "${oci_core_drg.test_londonvcn_drg.id}"
    }
}

resource "oci_core_security_list" "public_subnet_londonvcn" {
    provider       = "oci.london"

    compartment_id = "${var.compartment_ocid}"
    display_name   = "public_all"
    vcn_id         = "${oci_core_virtual_network.test_london_vcn.id}"

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
resource "oci_core_subnet" "public_subnet1_londonvcn" {
  provider            = "oci.london"
  cidr_block          = "${var.public_subnet1_london_cidr}"
  display_name        = "public_subnet1_londonvcn"
  dhcp_options_id     = "${oci_core_virtual_network.test_london_vcn.default_dhcp_options_id}"
  dns_label           = "pub1"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.test_london_vcn.id}"
  route_table_id      = "${oci_core_route_table.test_london_vcn_route_table.id}"
  security_list_ids   = ["${oci_core_security_list.public_subnet_londonvcn.id}"]
  prohibit_public_ip_on_vnic = true
}



