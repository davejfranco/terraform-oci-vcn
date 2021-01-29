# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? var.vcn_name : "${var.label_prefix}-${var.vcn_name}"
  dns_label      = var.vcn_dns_label

  freeform_tags  = var.tags
}

resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "internet-gateway" : "${var.label_prefix}-internet-gateway"

  freeform_tags = var.tags

  vcn_id = oci_core_vcn.vcn.id

  count = var.internet_gateway_enabled == true ? 1 : 0
}

resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "nat-gateway" : "${var.label_prefix}-nat-gateway"

  freeform_tags  = var.tags

  vcn_id         = oci_core_vcn.vcn.id

  count         = var.nat_gateway_enabled == true ? 1 : 0
}


data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
  count = var.service_gateway_enabled == true ? 1 : 0
}

resource "oci_core_service_gateway" "service_gateway" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "service-gateway" : "${var.label_prefix}-service-gateway"

  freeform_tags  = var.tags
  services {
    service_id = lookup(data.oci_core_services.all_oci_services[0].services[0], "id")
  }

  vcn_id = oci_core_vcn.vcn.id

  count = var.service_gateway_enabled == true ? 1 : 0
}
