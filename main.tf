terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
    }
  }
}

provider "aci" {
  # cisco-aci user name
  username = "admin"
  # cisco-aci password
  password = "ciscopsdt"
  # cisco-aci url
  url      = "https://sandboxapicdc.cisco.com/"
  insecure = true
}


resource "aci_tenant" "test-tenant" {
  name        = "test-tenant"
  description = "This tenant is created by terraform"
}

#resource "aci_tenant" "test-tenant2" {
#  name        = "test-tenant2"
#  description = "This tenant is created by terraform"
#}

##############################################################

#CDP Profile
resource "aci_cdp_interface_policy" "TF-CDP-ON" {
  name  = "TF-CDP-ON"
  admin_st  = "enabled"
}

# LLDP Profile
resource "aci_lldp_interface_policy" "TF-LLDP-TX-RX" {
  name        = "TF-LLDP-TX-RX"
  admin_rx_st = "enabled"
  admin_tx_st = "enabled"
}

# LACP suspend individual
resource "aci_lacp_policy" "TF-LACP-active-suspendindividual" {
  name        = "TF-LACP-active-suspendindividual"
  ctrl        = ["susp-individual"]
  mode        = "active"
}


resource "aci_leaf_access_bundle_policy_group" "TF-ESXi-1" {
    name                            = "TF-ESXi-1"
    lag_t                           = "node"
    relation_infra_rs_cdp_if_pol    = aci_cdp_interface_policy.TF-CDP-ON.id
    relation_infra_rs_lldp_if_pol   = aci_lldp_interface_policy.TF-LLDP-TX-RX.id
    relation_infra_rs_lacp_pol      = aci_lacp_policy.TF-LACP-active-suspendindividual.id
}


##########################################################################################
# Access

##########################################################################################
# Domain Profile

resource "aci_physical_domain" "TF-PHY-DOM" {
    name = "TF-PHY-DOM"
    relation_infra_rs_vlan_ns = aci_vlan_pool.TF-bare-VLAN.id
}


###########################################################################################
# VLAN Profile
resource "aci_vlan_pool" "TF-bare-VLAN" {
  name = "TF-bare-VLAN"
  alloc_mode = "static"
}

resource "aci_ranges" "TF-vlan_pool_1" {
  vlan_pool_dn = aci_vlan_pool.TF-bare-VLAN.id
  from = "vlan-100"
  to = "vlan-120"
  alloc_mode = "static"
  role = "external"
}



##########################################################################################
# AAEP

resource "aci_attachable_access_entity_profile" "TF-AAEP-bare" {
    name            =       "TF-AAEP-bare"
    relation_infra_rs_dom_p =       [aci_physical_domain.TF-PHY-DOM.id]
}
