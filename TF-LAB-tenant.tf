# TENANT
resource "aci_tenant" "TF-LAB" {
  name        = "TF-LAB"
  description = "This tenant is created by terraform"
}


# Application profile


# Bridge Domains
resource "aci_bridge_domain" "TF-webservers" {
  tenant_dn = aci_tenant.TF-LAB.id
  name = "TF-webservers"
  arp_flood = "yes"
  ip_learning = "yes"
  unicast_route = "yes"
  relation_fv_rs_ctx    = aci_vrf.TF_web_vrf.id
}

resource "aci_bridge_domain" "TF-dbs" {
  tenant_dn = aci_tenant.TF-LAB.id
  name = "TF-dbs"
  arp_flood = "yes"
  ip_learning = "yes"
  unicast_route = "yes"
  relation_fv_rs_ctx    = aci_vrf.TF_db_vrf.id
}


# Subnets
resource "aci_subnet" "TF-web-subnet" {
    parent_dn            = aci_bridge_domain.TF-webservers.id
    ip                   = "1.1.30.1/24"
    scope                = ["private"]
}

resource "aci_subnet" "TF-db-subnet" {
    parent_dn            = aci_bridge_domain.TF-dbs.id
    ip                   = "1.1.20.1/24"
    scope                = ["private"]
}

# VRF
resource "aci_vrf" "TF_web_vrf" {
  tenant_dn         = aci_tenant.TF-LAB.id
  name              = "TF_web_vrf"
}

resource "aci_vrf" "TF_db_vrf" {
  tenant_dn         = aci_tenant.TF-LAB.id
  name              = "TF_db_vrf"
}

# EPG
