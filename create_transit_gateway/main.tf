# ---------------------------------------------------------------------------------------------------------------
# Data source that extrapolates the Organizations ARN the account belongs to
# ---------------------------------------------------------------------------------------------------------------
data "aws_organizations_organization" "my_aws_organization" {}


# ---------------------------------------------------------------------------------------------------------------
# Object that contains a list of key value pairs that forms the tags added to a VPC on creation
# ---------------------------------------------------------------------------------------------------------------
locals {
  default_tags = {
    Name                 = join("-", [var.Application_Name, var.Environment_Type])
    Application_ID       = var.Application_ID
    Application_Name     = var.Application_Name
    Business_Unit        = var.Business_Unit
    CostCenterCode       = var.CostCenterCode
    CreatedBy            = var.CreatedBy
    Manager              = var.Manager
    Supported_Networks   = var.Supported_Networks
    Environment_Type     = var.Environment_Type
    Deployed_By          = "HashiCorp-Terraform"
  }
}

# ---------------------------------------------------------------------------------------------------------------
# Generates random alphanueric string for the preshared keys
# ---------------------------------------------------------------------------------------------------------------
resource "random_string" "alpha_numeric_value" {
  count = ( var.transit_gateway_deployment == true ? 2 :0 )
  length           = 16
  special          = false
}

# ---------------------------------------------------------------------------------------------------------------
# Checks the preshared key variables and generates keys if they are empty
# ---------------------------------------------------------------------------------------------------------------
locals{
    tunnel_1_preshared_key  = var.tunnel1_preshared_key== "" ? random_string.alpha_numeric_value[0].result : var.tunnel1_preshared_key
    tunnel_2_preshared_key  = var.tunnel2_preshared_key== "" ? random_string.alpha_numeric_value[1].result : var.tunnel2_preshared_key
}

# ---------------------------------------------------------------------------------------------------------------
# Generates random alphanueric string for the preshared keys
# ---------------------------------------------------------------------------------------------------------------
locals{
    tunnel_inside_cidrs     = length(var.tunnel_inside_cidrs) == 0 ? var.tunnel_cidrs : var.tunnel_inside_cidrs
}

# ---------------------------------------------------------------------------------------------------------------
# Transit Gateway Creation 
# ---------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway" "transit_gateway" {
  count = (var.transit_gateway_deployment == true ? 1 : 0)

  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = var.dns_support
  vpn_ecmp_support                = var.vpn_ecmp_support
  tags                            = local.default_tags
}


# ---------------------------------------------------------------------------------------------------------------
# AWS | Transit Gateway | --> Route Table Creation
# ---------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table" "shared_services_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  count              =  (var.route_tables.shared_services_route_table == true && var.enable_integration_with_network_deployer_solution == true) ? 1 : 0
  tags = {
    Name = "shared_services_route_table"
  }
}

resource "aws_ec2_transit_gateway_route_table" "north_south_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  count              =  (var.route_tables.shared_services_route_table == true && var.route_tables.north_south_route_table == true && var.enable_integration_with_network_deployer_solution == true) ? 1 : 0
  tags = {
    Name = "north_south_route_table"
  }
}

resource "aws_ec2_transit_gateway_route_table" "packet_inspection_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  count              =  (var.route_tables.shared_services_route_table == true && var.route_tables.packet_inspection_route_table == true && var.enable_integration_with_network_deployer_solution == true) ? 1 : 0
  tags = {
    Name = "packet_inspection_route_table"
  }
}


resource "aws_ec2_transit_gateway_route_table" "development_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  count              =  (var.route_tables.shared_services_route_table == true && var.route_tables.development_route_table == true && var.enable_integration_with_network_deployer_solution == true) ? 1 : 0
  tags = {
    Name = "development_inspection_route_table"
  }
}

resource "aws_ec2_transit_gateway_route_table" "production_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  count              =  (var.route_tables.shared_services_route_table == true && var.route_tables.production_route_table == true && var.enable_integration_with_network_deployer_solution == true) ? 1 : 0
  tags = {
    Name = "production_route_table"
  }
}

resource "aws_ec2_transit_gateway_route_table" "uat_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  count              =  (var.route_tables.shared_services_route_table == true && var.route_tables.uat_route_table == true && var.enable_integration_with_network_deployer_solution == true) ? 1 : 0
  tags = {
    Name = "uat_route_table"
  }
}

# ---------------------------------------------------------------------------------------------------------------
# AWS | Resource Access Manager | --> Creation
# ---------------------------------------------------------------------------------------------------------------
resource "aws_ram_resource_share" "share" {
  name                      = var.ram_share_name
  allow_external_principals = var.allow_external_principals
}


# ---------------------------------------------------------------------------------------------------------------
# AWS | Resource Access Manager | --> Principal Association with Resource Share
# ---------------------------------------------------------------------------------------------------------------
resource "aws_ram_principal_association" "share_principal_association" {
  principal          = data.aws_organizations_organization.my_aws_organization.arn
  resource_share_arn = aws_ram_resource_share.share.arn
}


# ---------------------------------------------------------------------------------------------------------------
# AWS | Resource Access Manager | --> Association with Resource Share
# ---------------------------------------------------------------------------------------------------------------
resource "aws_ram_resource_association" "share_transit_gateway" {
  resource_arn       = aws_ec2_transit_gateway.transit_gateway[0].arn
  resource_share_arn = aws_ram_resource_share.share.arn
}


# ---------------------------------------------------------------------------------------------------------------
# AWS | Resource Access Manager | --> Association with Resource Share
# ---------------------------------------------------------------------------------------------------------------
resource "aws_customer_gateway" "customer_gateway_1" {
  count = ( var.create_site_to_site_vpn == true ? 1 : 0 )
    bgp_asn    = var.remote_site_asn
    ip_address = var.remote_site_public_ip
    type       = var.vpn_type
}

resource "random_shuffle" "tunnel_cidr_ranges" {
 count = var.shuffle == true ? 2 : 0
  input        = local.tunnel_inside_cidrs
  result_count = var.how_many_vpn_connections
}

resource "aws_vpn_connection" "aws_site_to_site_vpn_1" {
   count = ( var.create_site_to_site_vpn == true ? var.how_many_vpn_connections : 0 )
    customer_gateway_id                   = aws_customer_gateway.customer_gateway_1[0].id
    transit_gateway_id                    = aws_ec2_transit_gateway.transit_gateway[0].id
    type                                  = aws_customer_gateway.customer_gateway_1[0].type
    enable_acceleration                   = var.enable_acceleration
    tunnel1_preshared_key                 = local.tunnel_1_preshared_key # var.tunnel1_preshared_key
    tunnel2_preshared_key                 = local.tunnel_2_preshared_key # var.tunnel2_preshared_key
    tunnel_inside_ip_version              = var.tunnel_inside_ip_version
    tunnel1_inside_cidr                   = random_shuffle.tunnel_cidr_ranges[0].result[count.index]
    tunnel2_inside_cidr                   = random_shuffle.tunnel_cidr_ranges[1].result[count.index]
    tunnel1_dpd_timeout_action            = var.tunnel1_dpd_timeout_action
    tunnel2_dpd_timeout_action            = var.tunnel2_dpd_timeout_action
    tunnel1_dpd_timeout_seconds           = var.tunnel1_dpd_timeout_seconds
    tunnel2_dpd_timeout_seconds           = var.tunnel2_dpd_timeout_seconds
    tunnel1_ike_versions                  = var.tunnel1_ike_versions
    tunnel2_ike_versions                  = var.tunnel2_ike_versions
    tunnel1_phase1_dh_group_numbers       = var.tunnel1_phase1_dh_group_numbers
    tunnel2_phase1_dh_group_numbers       = var.tunnel2_phase1_dh_group_numbers
    tunnel1_phase1_encryption_algorithms  = var.tunnel1_phase1_encryption_algorithms
    tunnel2_phase1_encryption_algorithms  = var.tunnel2_phase1_encryption_algorithms
    tunnel1_phase1_integrity_algorithms   = toset(var.tunnel1_phase1_integrity_algorithms)
    tunnel2_phase1_integrity_algorithms   = toset(var.tunnel2_phase1_integrity_algorithms)
    tunnel1_phase1_lifetime_seconds       = var.tunnel1_phase1_lifetime_seconds
    tunnel2_phase1_lifetime_seconds       = var.tunnel2_phase1_lifetime_seconds
    tunnel1_phase2_dh_group_numbers       = var.tunnel1_phase2_dh_group_numbers
    tunnel2_phase2_dh_group_numbers       = var.tunnel2_phase2_dh_group_numbers
    tunnel1_phase2_encryption_algorithms  = var.tunnel1_phase2_encryption_algorithms
    tunnel2_phase2_encryption_algorithms  = var.tunnel2_phase2_encryption_algorithms
    tunnel1_phase2_integrity_algorithms   = var.tunnel1_phase2_integrity_algorithms
    tunnel2_phase2_integrity_algorithms   = var.tunnel2_phase2_integrity_algorithms
    tunnel1_phase2_lifetime_seconds       = var.tunnel1_phase2_lifetime_seconds
    tunnel2_phase2_lifetime_seconds       = var.tunnel2_phase2_lifetime_seconds
    tunnel1_rekey_fuzz_percentage         = var.tunnel1_rekey_fuzz_percentage
    tunnel2_rekey_fuzz_percentage         = var.tunnel2_rekey_fuzz_percentage
    tunnel1_rekey_margin_time_seconds     = var.tunnel1_rekey_margin_time_seconds
    tunnel2_rekey_margin_time_seconds     = var.tunnel2_rekey_margin_time_seconds
    tunnel1_replay_window_size            = var.tunnel1_replay_window_size
    tunnel2_replay_window_size            = var.tunnel2_replay_window_size
    tunnel1_startup_action                = var.tunnel1_startup_action
    tunnel2_startup_action                = var.tunnel2_startup_action

}


# ---------------------------------------------------------------------------------------------------------------
# AWS Site-to-Site VPN | Propagation and Association with the North South Route Table
# ---------------------------------------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table_association" "aws_site_to_site_vpn_1_assoc_with_north_south_rte_table" {
  count = ( var.create_site_to_site_vpn == true && var.enable_integration_with_network_deployer_solution == true && var.route_tables.north_south_route_table == true ? var.how_many_vpn_connections : 0 )
  transit_gateway_attachment_id  = aws_vpn_connection.aws_site_to_site_vpn_1[count.index].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.north_south_route_table[0].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "aws_site_to_site_vpn_1_propagation_north_south" {
  count = ( var.create_site_to_site_vpn == true && var.enable_integration_with_network_deployer_solution == true && var.route_tables.north_south_route_table == true ? var.how_many_vpn_connections : 0 )
  transit_gateway_attachment_id  = aws_vpn_connection.aws_site_to_site_vpn_1[count.index].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.north_south_route_table[0].id
}

# ---------------------------------------------------------------------------------------------------------------
# AWS Site-to-Site VPN | Propagation to the Packet Inspection Route Table
# ---------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table_propagation" "aws_site_to_site_vpn_1_propagation_packet_inspection" {
  count = ( var.create_site_to_site_vpn == true && var.enable_integration_with_network_deployer_solution == true && var.route_tables.packet_inspection_route_table == true ? var.how_many_vpn_connections : 0 )
  transit_gateway_attachment_id  = aws_vpn_connection.aws_site_to_site_vpn_1[count.index].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.packet_inspection_route_table[0].id
}

# ---------------------------------------------------------------------------------------------------------------
# AWS Site-to-Site VPN | Propagation without packet inspection enabled on the transit gateway network
# ---------------------------------------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table_propagation" "aws_site_to_site_vpn_1_propagation_dev" {
  count = ( var.create_site_to_site_vpn == true && var.centralized_packet_inspection_enabled==false && var.enable_integration_with_network_deployer_solution == true && var.route_tables.development_route_table == true  ? var.how_many_vpn_connections : 0 )
  transit_gateway_attachment_id  = aws_vpn_connection.aws_site_to_site_vpn_1[count.index].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.development_route_table[0].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "aws_site_to_site_vpn_1_propagation_uat" {
  count = ( var.create_site_to_site_vpn == true && var.centralized_packet_inspection_enabled==false && var.enable_integration_with_network_deployer_solution == true && var.route_tables.uat_route_table == true ? var.how_many_vpn_connections : 0 )
  transit_gateway_attachment_id  = aws_vpn_connection.aws_site_to_site_vpn_1[count.index].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.uat_route_table[0].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "aws_site_to_site_vpn_1_propagation_prod" {
  count = ( var.create_site_to_site_vpn == true && var.centralized_packet_inspection_enabled==false && var.enable_integration_with_network_deployer_solution == true && var.route_tables.production_route_table == true ? var.how_many_vpn_connections : 0 )
  transit_gateway_attachment_id  = aws_vpn_connection.aws_site_to_site_vpn_1[count.index].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.production_route_table[0].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "aws_site_to_site_vpn_1_propagation_shared_services" {
  count = ( var.create_site_to_site_vpn == true && var.centralized_packet_inspection_enabled==false && var.enable_integration_with_network_deployer_solution == true && var.route_tables.shared_services_route_table == true ? var.how_many_vpn_connections : 0 )
  transit_gateway_attachment_id  = aws_vpn_connection.aws_site_to_site_vpn_1[count.index].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_services_route_table[0].id
}

