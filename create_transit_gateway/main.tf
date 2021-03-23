# ---------------------------------------------------------------------------------------------------------------
#
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
# Data source that extrapolates the Organizations ARN the account belongs to
# ---------------------------------------------------------------------------------------------------------------
data "aws_organizations_organization" "my_aws_organization" {}


# ---------------------------------------------------------------------------------------------------------------
# Transit Gateway Creation 
# ---------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway" "transit_gateway" {
  count = (var.transit_gateway_deployment == false ? 1 : 0)

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
  count              = var.route_tables.shared_services_route_table == true ? 1 : 0
  tags = {
    Name = "shared_services_route_table"
  }
}

resource "aws_ec2_transit_gateway_route_table" "north_south_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  count              = var.route_tables.north_south_route_table == true ? 1 : 0
  tags = {
    Name = "north_south_route_table"
  }
}

resource "aws_ec2_transit_gateway_route_table" "packet_inspection_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  count              = var.route_tables.packet_inspection_route_table == true ? 1 : 0
  tags = {
    Name = "packet_inspection_route_table"
  }
}


resource "aws_ec2_transit_gateway_route_table" "development_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  count              = var.route_tables.development_route_table == true ? 1 : 0
  tags = {
    Name = "development_inspection_route_table"
  }
}

resource "aws_ec2_transit_gateway_route_table" "production_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  count              = var.route_tables.production_route_table == true ? 1 : 0
  tags = {
    Name = "production_route_table"
  }
}

resource "aws_ec2_transit_gateway_route_table" "uat_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  count              = var.route_tables.uat_route_table == true ? 1 : 0
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

resource "aws_vpn_connection" "aws_site_to_site_vpn_1" {
   count = ( var.create_site_to_site_vpn == true ? var.how_many_vpn_connections : 0 )
    customer_gateway_id = aws_customer_gateway.customer_gateway_1[0].id
    transit_gateway_id  = aws_ec2_transit_gateway.transit_gateway[0].id
    type                = aws_customer_gateway.customer_gateway_1[0].type
    # tunnel1_preshared_key = ""
    # tunnel2_preshared_key = ""
}

//resource "aws_ec2_transit_gateway_route_table_propagation" "aws_site_to_site_vpn_1_propagation_shared_services" {
//  transit_gateway_attachment_id  = aws_vpn_connection.aws_site_to_site_vpn_1.id # aws_ec2_transit_gateway_vpc_attachment.example.id
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_services_route_table.id
//}

