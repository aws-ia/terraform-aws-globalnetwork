# ----------------------------------------------------------------------------
# Provider declaration
# ----------------------------------------------------------------------------
terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

# ----------------------------------------------------------------------------
# There is no need to configure any variable in the main.tf
# All configuration is already complete.
# ----------------------------------------------------------------------------
module "main" {
  source = "../.."
}

/*
----------------------------------------------------------------------------
   It important to note the following:
----------------------------------------------------------------------------
   1. A transit gateway can be deployed in any region. This solution allows you
      to deploy a transit gateway in a region by changing the boolean flag in the
      variable "deploy_transit_gateway_in_this_aws_region" to true.
   2. That said, for testing purposes, ensure that local.transit_gateway_id
      is set to the region where your transit gateway is deployed.

      For example.
      --------------
      if your test is being conducted for a transit gateway deployment in the AWS Ohio Region
      then the locals configuration would be as follows:

      locals {
            transit_gateway_id = module.main.ohio_transit_gateway_id
      }
----------------------------------------------------------------------------
*/

locals {
  transit_gateway_id = module.main.ohio_transit_gateway_id
}

# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "transit_gateway" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.transit_gateway_id))
  }
}
