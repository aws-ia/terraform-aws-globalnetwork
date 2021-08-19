##################################################################################################################
# This module deploys the transit gateway network that your business requires.
# To do this, simply configure the variables outlined in the terraform.tfvars file.
##################################################################################################################

module "deploy_aws_transit_gateway_network"{
  source = "../"
  ################################################################################################################
  # AWS TRANSIT GATEWAY CONFIGURATIONS
  ################################################################################################################
  ram_share_name                                    = var.ram_share_name
  deploy_transit_gateway_in_this_aws_region         = var.deploy_transit_gateway_in_this_aws_region
  transit_gateway_peering                           = var.transit_gateway_peering
  dns_support                                       = var.dns_support
  network_manager_deployment                        = var.network_manager_deployment
  network_manager_name                              = var.network_manager_name
  network_manager_id                                = var.network_manager_id
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution
  default_route_table_propagation                   = var.default_route_table_propagation
  default_route_table_association                   = var.default_route_table_association
  vpn_ecmp_support                                  = var.vpn_ecmp_support
  centralized_packet_inspection_enabled             = var.centralized_packet_inspection_enabled
  ################################################################################################################
  # AWS SITE TO SITE VPN CONFIGURATION
  ################################################################################################################
  create_site_to_site_vpn                           = var.create_site_to_site_vpn
  remote_site_asn                                   = var.remote_site_asn
  remote_site_public_ip                             = var.remote_site_public_ip
  how_many_vpn_connections                          = var.how_many_vpn_connections
  enable_acceleration                               = var.enable_acceleration
  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
  tunnel_inside_cidrs                               = var.tunnel_inside_cidrs
  tunnel1_preshared_key                             = var.tunnel1_preshared_key
  tunnel2_preshared_key                             = var.tunnel2_preshared_key
  tunnel1_dpd_timeout_action                        = var.tunnel1_dpd_timeout_action
  tunnel2_dpd_timeout_action                        = var.tunnel2_dpd_timeout_action
  tunnel1_dpd_timeout_seconds                       = var.tunnel1_dpd_timeout_seconds
  tunnel2_dpd_timeout_seconds                       = var.tunnel2_dpd_timeout_seconds
  tunnel1_ike_versions                              = var.tunnel1_ike_versions
  tunnel2_ike_versions                              = var.tunnel2_ike_versions
  tunnel1_phase1_dh_group_numbers                   = var.tunnel1_phase1_dh_group_numbers
  tunnel2_phase1_dh_group_numbers                   = var.tunnel2_phase1_dh_group_numbers
  tunnel1_phase1_encryption_algorithms              = var.tunnel1_phase1_encryption_algorithms
  tunnel2_phase1_encryption_algorithms              = var.tunnel2_phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms               = var.tunnel1_phase1_integrity_algorithms
  tunnel2_phase1_integrity_algorithms               = var.tunnel2_phase1_integrity_algorithms
  tunnel1_phase1_lifetime_seconds                   = var.tunnel1_phase1_lifetime_seconds
  tunnel2_phase1_lifetime_seconds                   = var.tunnel2_phase1_lifetime_seconds
  tunnel1_phase2_dh_group_numbers                   = var.tunnel1_phase2_dh_group_numbers
  tunnel2_phase2_dh_group_numbers                   = var.tunnel2_phase2_dh_group_numbers
  tunnel1_phase2_encryption_algorithms              = var.tunnel1_phase2_encryption_algorithms
  tunnel2_phase2_encryption_algorithms              = var.tunnel2_phase2_encryption_algorithms
  tunnel1_phase2_integrity_algorithms               = var.tunnel1_phase2_integrity_algorithms
  tunnel2_phase2_integrity_algorithms               = var.tunnel2_phase2_integrity_algorithms
  tunnel1_phase2_lifetime_seconds                   = var.tunnel1_phase2_lifetime_seconds
  tunnel2_phase2_lifetime_seconds                   = var.tunnel2_phase2_lifetime_seconds
  tunnel1_rekey_fuzz_percentage                     = var.tunnel1_rekey_fuzz_percentage
  tunnel2_rekey_fuzz_percentage                     = var.tunnel2_rekey_fuzz_percentage
  tunnel1_rekey_margin_time_seconds                 = var.tunnel1_rekey_margin_time_seconds
  tunnel2_rekey_margin_time_seconds                 = var.tunnel2_rekey_margin_time_seconds
  tunnel1_replay_window_size                        = var.tunnel1_replay_window_size
  tunnel2_replay_window_size                        = var.tunnel2_replay_window_size
  tunnel1_startup_action                            = var.tunnel1_startup_action
  tunnel2_startup_action                            = var.tunnel2_startup_action
  ################################################################################################################
  # AWS TAGS
  ################################################################################################################
  Business_Unit                                     = var.Business_Unit
  Environment_Type                                  = var.Environment_Type
  Supported_Networks                                = var.Supported_Networks
  CostCenterCode                                    = var.CostCenterCode
  CreatedBy                                         = var.CreatedBy
  Manager                                           = var.Manager
}

