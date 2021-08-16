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

  #-----------------------------------------------------------------------------------------------------
  #  AWS Transit Gateway | --->  Create Transit Gateway
  #-----------------------------------------------------------------------------------------------------
  # This variable controls the creation of a transit gateway in the region to the left.
  # Simply set true if you want to create or false if you dont want to create.
  # The option "all_aws_region" allows you to create a transit gateway in all AWS Region.
  # There's no need to specify true for individual regions if "all_aws_region" is set to true.
  #-----------------------------------------------------------------------------------------------------
  deploy_transit_gateway_in_this_aws_region = {
    all_aws_regions                       = true  # false
    ohio                                  = false # false
    n_virginia                            = false # false
    oregon                                = false # true
    n_california                          = false # true
    canada_east                           = false # true
    ireland                               = false # true
    london                                = false # true
    stockholm                             = false # true
    frankfurt                             = false # true
    paris                                 = false # true
    tokyo                                 = false # true
    seoul                                 = false # true
    sydney                                = false # true
    mumbai                                = false # true
    singapore                             = false # true
    sao-paulo                             = false # true
  }
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
  ohio_transit_gateway_id                                  = module.main.ohio_transit_gateway_id
  n_virginia_transit_gateway_id                            = module.main.n_virginia_transit_gateway_id
  oregon_transit_gateway_id                                = module.main.oregon_transit_gateway_id
  n_california_transit_gateway_id                          = module.main.n_california_transit_gateway_id
  canada_east_transit_gateway_id                           = module.main.canada_montreal_transit_gateway_id
  ireland_transit_gateway_id                               = module.main.ireland_transit_gateway_id
  london_transit_gateway_id                                = module.main.london_transit_gateway_id
  stockholm_transit_gateway_id                             = module.main.stockholm_transit_gateway_id
  frankfurt_transit_gateway_id                             = module.main.frankfurt_transit_gateway_id
  paris_transit_gateway_id                                 = module.main.paris_transit_gateway_id
  tokyo_transit_gateway_id                                 = module.main.tokyo_transit_gateway_id
  seoul_transit_gateway_id                                 = module.main.seoul_transit_gateway_id
  sydney_transit_gateway_id                                = module.main.sydney_transit_gateway_id
  mumbai_transit_gateway_id                                = module.main.mumbai_transit_gateway_id
  singapore_transit_gateway_id                             = module.main.singapore_transit_gateway_id
  sao-paulo_transit_gateway_id                             = module.main.sao_paulo_transit_gateway_id
}



# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_ohio" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.ohio_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.ohio_transit_gateway_id))
  }
}

# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_n_virginia" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.n_virginia_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.n_virginia_transit_gateway_id))
  }
}

# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_n_california" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.n_california_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.n_california_transit_gateway_id))
  }
}

# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_oregon" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.oregon_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.oregon_transit_gateway_id))
  }
}

# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_canada_east" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.canada_east_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.canada_east_transit_gateway_id))
  }
}

# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_ireland" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.ireland_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.ireland_transit_gateway_id))
  }
}

# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_london" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.london_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.london_transit_gateway_id))
  }
}


# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_stockholm" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.stockholm_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.stockholm_transit_gateway_id))
  }
}


# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_frankfurt" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.frankfurt_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.frankfurt_transit_gateway_id))
  }
}


# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_paris" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.paris_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.paris_transit_gateway_id))
  }
}


# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_tokyo" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.tokyo_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.tokyo_transit_gateway_id))
  }
}


# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_seoul" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.seoul_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.seoul_transit_gateway_id))
  }
}

# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_singapore" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.singapore_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.singapore_transit_gateway_id))
  }
}

# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_mumbai" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.mumbai_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.mumbai_transit_gateway_id))
  }
}

# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_sydney" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.sydney_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.sydney_transit_gateway_id))
  }
}

# ----------------------------------------------------------------------------
# This Assertion checks that the transit gateway id prefix is correct and
# aligns with the AWS standard for AWS Transit Gateways
# ----------------------------------------------------------------------------
resource "test_assertions" "testing_transit_gateway_id_compliance_in_sao_paulo" {
  # "component" is an unique identifier for this
  # particular set of assertions in the test results.
  component = "transit_gateway_id"

  equal "scheme" {
    description = "Default scheme is tgw-"
    got         = local.sao-paulo_transit_gateway_id
    want        = "tgw-"
  }

  check "transit_gateway_id_prefix" {
    description = "Check for transit gateway id prefix alignment."
    condition   = can(regex("^tgw-", local.sao-paulo_transit_gateway_id))
  }
}
