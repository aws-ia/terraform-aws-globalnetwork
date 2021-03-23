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
  }
}

resource "aws_ec2_transit_gateway_peering_attachment" "transit_gateway_peering_request" {
  count = (var.transit_gateway_deployment == true && var.transit_gateway_peering_enabled == true ? 1 : 0)

  peer_account_id         = var.peer_account_id
  peer_region             = var.peer_region
  peer_transit_gateway_id = var.peer_transit_gateway_id
  transit_gateway_id      = var.transit_gateway_id

  tags =  local.default_tags

}



