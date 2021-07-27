# ---------------------------------------------------------------------------------------------------------------
# Allows the addition of validation to this terraform module.
# ---------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "first" {
  provider = aws.ohio
}


resource "aws_iam_role_policy" "lambda_tgw_globalnetwork_attach_policy" {
  name = "lambda_tgw_globalnetwork_attach_policy"
  role = aws_iam_role.iam_for_lambda_tgw_globalnetwork_attach.id

  # Terraform "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  # IAM Policy Statement
  # ---------------------------------------------------------------------------------------------------------------
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*",
        "Effect": "Allow",
        "Condition": {
          "StringEquals": {
            "aws:PrincipalAccount": "${data.aws_caller_identity.first.account_id}"
          }
        }
      },
      {
        "Action": ["networkmanager:*", "ec2:*"],
        "Resource": "*",
        "Effect": "Allow",
        "Condition": {
          "StringEquals": {
            "aws:PrincipalAccount": "${data.aws_caller_identity.first.account_id}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "iam_for_lambda_tgw_globalnetwork_attach" {
  name = "iam_for_lambda_tgw_globalnetwork_attach"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "zip"{
  type = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "random_uuid" "uuid_lambda_spoke" { }

resource "aws_lambda_function" "lambda_globalnetwork_tgw_attach" {
  filename      = data.archive_file.zip.output_path
  function_name = join("_", ["lambda-gn-tgw", random_uuid.uuid_lambda_spoke.result])
  role          = aws_iam_role.iam_for_lambda_tgw_globalnetwork_attach.arn
  handler       = "lambda_function.lambda_handler"
  runtime = "python3.8"
  timeout          = 900

  environment {
    variables = {
      GlobalNetworkId = var.network_manager_id
      # GlobalNetworkId = data.aws_cloudformation_stack.network-manager-id.outputs["GlobalNetworkId"]

    }
  }
}


#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | ---> DEPLOYS TRANSIT GATEWAYS  
#-----------------------------------------------------------------------------------------------------

# NORTHERN VIRGINIA : us-east-1
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-n_virginia" {
  source = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.n_virginia == true) ? 1:0)
  providers = {
    aws = aws.n_virginia
  }

  create_site_to_site_vpn = var.create_site_to_site_vpn.n_virginia
  remote_site_public_ip = var.remote_site_public_ip.n_virginia # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.n_virginia             # var.remote_site_asn.hq
  amazon_side_asn = "64512" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}

data "aws_lambda_invocation" "tgw-globalnetwork-attach-n_virginia" {
  count = ((var.network_manager_deployment==true &&  var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.n_virginia == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-n_virginia[0].transit_gateway_arn}"
  }
  JSON
}

# OHIO : us-east-2
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-ohio" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.ohio == true) ? 1:0)
  providers = {
    aws = aws.ohio
  }
  create_site_to_site_vpn = var.create_site_to_site_vpn.ohio
  remote_site_public_ip = var.remote_site_public_ip.ohio # var.remote_site_public_ip.hq
  amazon_side_asn = "64513" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.
  remote_site_asn = var.remote_site_asn.ohio

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}

data "aws_lambda_invocation" "tgw-globalnetwork-attach-ohio" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.ohio == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-ohio[0].transit_gateway_arn}"
  }
  JSON
}

# NORTHERN CALIFORNIA : us-west-1
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-n_california" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.n_california == true) ? 1:0)
  providers = {
    aws = aws.n_california
  }

  create_site_to_site_vpn = var.create_site_to_site_vpn.n_california
  remote_site_public_ip = var.remote_site_public_ip.n_california # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.n_california

  amazon_side_asn = "64514" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.
  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}

data "aws_lambda_invocation" "tgw-globalnetwork-attach-n_california" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.n_california == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-n_california[0].transit_gateway_arn}"
  }
  JSON
}

# OREGON : us-west-2
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-oregon" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.oregon == true) ? 1:0)
  providers = {
    aws = aws.oregon
  }

  create_site_to_site_vpn = var.create_site_to_site_vpn.oregon
  remote_site_public_ip = var.remote_site_public_ip.oregon # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.oregon
  amazon_side_asn = "64515" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}

data "aws_lambda_invocation" "tgw-globalnetwork-attach-oregon" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.oregon == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-oregon[0].transit_gateway_arn}"
  }
  JSON
}

# CANADA-MONTREAL : ca-central-1
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-canada-montreal" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.canada_east == true) ? 1:0)
  providers = {
    aws = aws.canada_east
  }

  create_site_to_site_vpn = var.create_site_to_site_vpn.canada_east
  remote_site_public_ip = var.remote_site_public_ip.canada_east # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.canada_east
  amazon_side_asn = "64516" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}

data "aws_lambda_invocation" "tgw-globalnetwork-attach-canada-montreal" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.canada_east == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-canada-montreal[0].transit_gateway_arn}"
  }
  JSON
}

# MUMBAI  : ap-south-1
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-mumbai" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.mumbai == true) ? 1:0)
  providers = {
    aws = aws.mumbai
  }

  create_site_to_site_vpn = var.create_site_to_site_vpn.mumbai
  remote_site_public_ip = var.remote_site_public_ip.mumbai  # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.mumbai
  amazon_side_asn = "64519" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


data "aws_lambda_invocation" "tgw-globalnetwork-attach-mumbai" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.mumbai == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-mumbai[0].transit_gateway_arn}"
  }
  JSON
}

# SEOUL : ap-northeast-2
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-seoul" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.seoul == true) ? 1:0)
  providers = {
    aws = aws.seoul
  }

  create_site_to_site_vpn = var.create_site_to_site_vpn.seoul
  remote_site_public_ip = var.remote_site_public_ip.seoul  # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.seoul
  amazon_side_asn = "64521" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}
data "aws_lambda_invocation" "tgw-globalnetwork-attach-seoul" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.seoul == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-seoul[0].transit_gateway_arn}"
  }
  JSON
}

# SINGAPORE  : ap-southeast-1
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-singapore" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.singapore == true) ? 1:0)
  providers = { aws = aws.singapore }

  create_site_to_site_vpn = var.create_site_to_site_vpn.singapore
  remote_site_public_ip = var.remote_site_public_ip.singapore  # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.singapore
  amazon_side_asn = "64522" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


data "aws_lambda_invocation" "tgw-globalnetwork-attach-singapore" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.singapore == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-singapore[0].transit_gateway_arn}"
  }
  JSON
}


# SYDNEY : ap-southeast-2
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-sydney" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.sydney == true) ? 1:0)
  providers = { aws = aws.sydney }

  create_site_to_site_vpn = var.create_site_to_site_vpn.sydney
  remote_site_public_ip = var.remote_site_public_ip.sydney  # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.sydney
  amazon_side_asn = "64523" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}

data "aws_lambda_invocation" "tgw-globalnetwork-attach-sydney" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.sydney == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-sydney[0].transit_gateway_arn}"
  }
  JSON
}

# TOKYO : ap-northeast-1
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-tokyo" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.tokyo == true) ? 1:0)
  providers = { aws = aws.tokyo }

  create_site_to_site_vpn = var.create_site_to_site_vpn.tokyo
  remote_site_public_ip = var.remote_site_public_ip.tokyo  # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.tokyo
  amazon_side_asn = "64524" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}

data "aws_lambda_invocation" "tgw-globalnetwork-attach-tokyo" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.tokyo == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-tokyo[0].transit_gateway_arn}"
  }
  JSON
}

# FRANKFURT : eu-central-1
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-frankfurt" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.frankfurt == true) ? 1:0)
  providers = { aws = aws.frankfurt }

  create_site_to_site_vpn = var.create_site_to_site_vpn.frankfurt
  remote_site_public_ip = var.remote_site_public_ip.frankfurt  # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.frankfurt
  amazon_side_asn = "64525" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}

data "aws_lambda_invocation" "tgw-globalnetwork-attach-frankfurt" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.frankfurt == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-frankfurt[0].transit_gateway_arn}"
  }
  JSON
}

# IRELAND : eu-west-1
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-ireland" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.ireland == true) ? 1:0)
  providers = { aws = aws.ireland }

  create_site_to_site_vpn = var.create_site_to_site_vpn.ireland
  remote_site_public_ip = var.remote_site_public_ip.ireland  # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.ireland
  amazon_side_asn = "64526" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}

data "aws_lambda_invocation" "tgw-globalnetwork-attach-ireland" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.ireland == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-ireland[0].transit_gateway_arn}"
  }
  JSON
}

# LONDON : eu-west-2
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-london" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.london == true) ? 1:0)
  providers = { aws = aws.london }

  create_site_to_site_vpn = var.create_site_to_site_vpn.london
  remote_site_public_ip = var.remote_site_public_ip.london  # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.london
  amazon_side_asn = "64527" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}

data "aws_lambda_invocation" "tgw-globalnetwork-attach-london" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.london == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-london[0].transit_gateway_arn}"
  }
  JSON
}

# PARIS : eu-west-3
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-paris" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.paris == true) ? 1:0)
  providers = { aws = aws.paris }

  create_site_to_site_vpn = var.create_site_to_site_vpn.paris
  remote_site_public_ip = var.remote_site_public_ip.paris  # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.paris
  amazon_side_asn = "64528" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}

data "aws_lambda_invocation" "tgw-globalnetwork-attach-paris" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.paris == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-paris[0].transit_gateway_arn}"
  }
  JSON
}

# STOCKHOLM : eu-north-1
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-stockholm" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.stockholm == true) ? 1:0)
  providers = { aws = aws.stockholm }

  create_site_to_site_vpn = var.create_site_to_site_vpn.stockholm
  remote_site_public_ip = var.remote_site_public_ip.stockholm  # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.stockholm
  amazon_side_asn = "64530" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}

data "aws_lambda_invocation" "tgw-globalnetwork-attach-stockholm" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.stockholm == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-stockholm[0].transit_gateway_arn}"
  }
  JSON
}

# SAO PAULO : sa-east-1
//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-deployment-sao-paulo" {
  source                = "./create_transit_gateway"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true) ? 1:0)
  providers = { aws = aws.sao_paulo }

  create_site_to_site_vpn = var.create_site_to_site_vpn.sao_paulo
  remote_site_public_ip = var.remote_site_public_ip.sao-paulo  # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.sao-paulo
  amazon_side_asn = "64532" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.

  transit_gateway_deployment = false
  how_many_vpn_connections = var.how_many_vpn_connections
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


data "aws_lambda_invocation" "tgw-globalnetwork-attach-sao-paulo" {
  count = ((var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true) || (var.network_manager_deployment==true && var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true) ? 1:0)
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach.function_name
  input = <<JSON
  {
    "tgw_arn": "${module.terraform-aws-fsf-tgw-deployment-sao-paulo[0].transit_gateway_arn}"
  }
  JSON
}


#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | ---> PEERS TRANSIT GATEWAYS  
#-----------------------------------------------------------------------------------------------------

# PEERING : OHIO & NORTHERN VIRGINIA
#-----------------------------------------
# REQUESTER REGION : OHIO
# ACCEPTOR : NORTHERN VIRGINIA
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-ohio-n-virginia" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true|| (var.deploy_transit_gateway_in_this_aws_region.n_virginia == true && var.deploy_transit_gateway_in_this_aws_region.ohio == true) ) && (var.transit_gateway_peering.ohio_n_virginia == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.ohio }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "us-east-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-n_virginia[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-ohio[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true|| (var.deploy_transit_gateway_in_this_aws_region.n_virginia == true && var.deploy_transit_gateway_in_this_aws_region.ohio == true) ) && (var.transit_gateway_peering.ohio_n_virginia == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.n_virginia
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-ohio-n-virginia[0].transit_gateway_peering_attachment_id
}


# PEERING : OHIO & CANADA_EAST (MONTREAL)
#-----------------------------------------

############################## AMERICAN NORTHEAST ##############################

# REQUESTER REGION : OHIO
# ACCEPTOR : CANADA_EAST
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-ohio-n-canada_east" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.ohio == true && var.deploy_transit_gateway_in_this_aws_region.canada_east == true) ) && (var.transit_gateway_peering.ohio_canada_east == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.ohio }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "ca-central-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-canada-montreal[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-ohio[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-ohio-n-canada-east" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.ohio == true && var.deploy_transit_gateway_in_this_aws_region.canada_east == true) ) && (var.transit_gateway_peering.ohio_canada_east == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.canada_east
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-ohio-n-canada_east[0].transit_gateway_peering_attachment_id
}


# PEERING : CANADA_EAST (MONTREAL) & NORTHERN VIRGINIA
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : NORTHERN VIRGINIA
# ACCEPTOR : CANADA_EAST
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-n_virginia-n-canada_east" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.n_virginia == true && var.deploy_transit_gateway_in_this_aws_region.canada_east == true) ) && (var.transit_gateway_peering.n_virginia_canada_east == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.n_virginia }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "ca-central-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-canada-montreal[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-n_virginia[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-n_virginia-n-canada-east" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.n_virginia == true && var.deploy_transit_gateway_in_this_aws_region.canada_east == true) ) && (var.transit_gateway_peering.n_virginia_canada_east == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.canada_east
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-n_virginia-n-canada_east[0].transit_gateway_peering_attachment_id
}


############################## AMERICAN NORTHWEST ##############################

# PEERING : OREGON & NORTHERN CALIFORNIA
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : OREGON
# ACCEPTOR : NORTHERN CALIFORNIA
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-oregon-n-california" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.n_california == true && var.deploy_transit_gateway_in_this_aws_region.oregon == true) ) && (var.transit_gateway_peering.oregon_n_california == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.oregon }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "us-west-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-n_california[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-oregon[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager


}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-n_california-n-oregon" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.n_california == true && var.deploy_transit_gateway_in_this_aws_region.oregon == true) )  && (var.transit_gateway_peering.oregon_n_california == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.n_california
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-oregon-n-california[0].transit_gateway_peering_attachment_id
}


############################## AMERICAN NORTHWEST : CONNECTING TO : AMERICAN NORTHEAST ##############################

# PEERING : OREGON & OHIO
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : OREGON
# ACCEPTOR : OHIO
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-oregon-n-ohio" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.ohio == true && var.deploy_transit_gateway_in_this_aws_region.oregon == true) )   && (var.transit_gateway_peering.ohio_oregon == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.oregon }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "us-east-2"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-ohio[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-oregon[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager


}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-oregon-n-ohio" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.ohio == true && var.deploy_transit_gateway_in_this_aws_region.oregon == true) )   && (var.transit_gateway_peering.ohio_oregon == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.ohio
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-oregon-n-ohio[0].transit_gateway_peering_attachment_id
}


# PEERING : OREGON & NORTHERN VIRGINIA
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : OREGON
# ACCEPTOR : NORTHERN VIRGINIA
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-oregon-n-n_virginia" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.n_virginia == true && var.deploy_transit_gateway_in_this_aws_region.oregon == true) )   && (var.transit_gateway_peering.oregon_n_virginia == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.oregon }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "us-east-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-n_virginia[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-oregon[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager


}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-oregon-n-n_virginia" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.n_virginia == true && var.deploy_transit_gateway_in_this_aws_region.oregon == true) ) && (var.transit_gateway_peering.oregon_n_virginia == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.n_virginia
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-oregon-n-n_virginia[0].transit_gateway_peering_attachment_id
}


# PEERING : OREGON & CANADA_EAST
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : OREGON
# ACCEPTOR : CANADA_EAST
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-oregon-n-canada-east" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.canada_east == true && var.deploy_transit_gateway_in_this_aws_region.oregon == true) ) && (var.transit_gateway_peering.oregon_canada_east == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = {
    aws = aws.oregon
  }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "ca-central-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-canada-montreal[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-oregon[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager


}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-oregon-n-canada-east" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.canada_east == true && var.deploy_transit_gateway_in_this_aws_region.oregon == true) )  && (var.transit_gateway_peering.oregon_canada_east == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.canada_east
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-oregon-n-canada-east[0].transit_gateway_peering_attachment_id
}


# PEERING : NORTHERN CALIFORNIA & OHIO
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : NORTHERN CALIFORNIA
# ACCEPTOR : OHIO
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-n_california-n-ohio" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.n_california == true && var.deploy_transit_gateway_in_this_aws_region.ohio == true) )  && (var.transit_gateway_peering.ohio_n_california == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = {
    aws = aws.n_california
  }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "us-east-2"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-ohio[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-n_california[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager


}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-n_california-n-ohio" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.n_california == true && var.deploy_transit_gateway_in_this_aws_region.ohio == true) )  && (var.transit_gateway_peering.ohio_n_california == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.ohio
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-n_california-n-ohio[0].transit_gateway_peering_attachment_id
}


# PEERING : NORTHERN CALIFORNIA & NORTHERN VIRGINIA
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : NORTHERN CALIFORNIA
# ACCEPTOR : NORTHERN VIRGINIA
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-n_california-n-n_virginia" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.n_california == true && var.deploy_transit_gateway_in_this_aws_region.n_virginia == true) ) && (var.transit_gateway_peering.n_california_n_virginia == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.n_california }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "us-east-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-n_virginia[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-n_california[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-n_california-n-n_virginia" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.n_california == true && var.deploy_transit_gateway_in_this_aws_region.n_virginia == true) )  && (var.transit_gateway_peering.n_california_n_virginia == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.n_virginia
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-n_california-n-n_virginia[0].transit_gateway_peering_attachment_id
}



############################## AMERICA : CONNECTING TO : SAO PAULO ##############################

# PEERING : NORTHEAST AMERICA  WITH SAO PAULO
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : NORTHERN VIRGINIA
# ACCEPTOR : SAO PAULO
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-n_virginia-n-sao-paulo" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true && var.deploy_transit_gateway_in_this_aws_region.n_virginia == true) )  && (var.transit_gateway_peering.n_virginia_sao_paulo == true || var.transit_gateway_peering.build_complete_mesh == true)  ? 1:0)
  providers = { aws = aws.n_virginia }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "sa-east-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-sao-paulo[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-n_virginia[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-n_virginia-n-sao-paulo" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true && var.deploy_transit_gateway_in_this_aws_region.n_virginia == true) )  && (var.transit_gateway_peering.n_virginia_sao_paulo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.sao_paulo
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-n_virginia-n-sao-paulo[0].transit_gateway_peering_attachment_id
}



# PEERING : NORTHWEST AMERICA  WITH SAO PAULO
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : OREGON
# ACCEPTOR : SAO PAULO
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-oregon-n-sao-paulo" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true && var.deploy_transit_gateway_in_this_aws_region.oregon == true) )  && (var.transit_gateway_peering.oregon_n_sao_paulo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.oregon }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "sa-east-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-sao-paulo[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-oregon[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager


}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-oregon-n-sao-paulo" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true && var.deploy_transit_gateway_in_this_aws_region.oregon == true) )  && (var.transit_gateway_peering.oregon_n_sao_paulo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.sao_paulo
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-oregon-n-sao-paulo[0].transit_gateway_peering_attachment_id
}


############################## AMERICA : CONNECTING TO : EUROPE ##############################

# PEERING : NORTHEAST AMERICA  WITH LONDON
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : NORTHERN VIRGINIA
# ACCEPTOR : LONDON
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-n_virginia-n-london" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.n_virginia == true && var.deploy_transit_gateway_in_this_aws_region.london == true) )  && (var.transit_gateway_peering.n_virginia_n_london == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.n_virginia }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "eu-west-2"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-london[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-n_virginia[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-n_virginia-n-london" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.n_virginia == true && var.deploy_transit_gateway_in_this_aws_region.london == true) )  && (var.transit_gateway_peering.n_virginia_n_london == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.london
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-n_virginia-n-london[0].transit_gateway_peering_attachment_id
}



# PEERING : NORTHWEST AMERICA  WITH LONDON
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : OREGON
# ACCEPTOR : LONDON
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-oregon-n-london" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.oregon == true && var.deploy_transit_gateway_in_this_aws_region.london == true) )  && (var.transit_gateway_peering.oregon_n_london == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.oregon }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "eu-west-2"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-london[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-oregon[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager


}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-oregon-n-london" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.oregon == true && var.deploy_transit_gateway_in_this_aws_region.london == true) )  && (var.transit_gateway_peering.oregon_n_london == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.london
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-oregon-n-london[0].transit_gateway_peering_attachment_id
}




############################## EUROPE : CONNECTING TO : EUROPE ##############################

# PEERING : LONDON WITH IRELAND
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : LONDON
# ACCEPTOR : IRELAND
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-london-n-ireland" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.ireland == true && var.deploy_transit_gateway_in_this_aws_region.london == true) )  && (var.transit_gateway_peering.london_n_ireland == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.london }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "eu-west-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-ireland[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-london[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-london-n-ireland" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.ireland == true && var.deploy_transit_gateway_in_this_aws_region.london == true) )  && (var.transit_gateway_peering.london_n_ireland == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.ireland
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-london-n-ireland[0].transit_gateway_peering_attachment_id
}


# PEERING : LONDON WITH PARIS
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : LONDON
# ACCEPTOR : PARIS
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-london-n-paris" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.paris == true && var.deploy_transit_gateway_in_this_aws_region.london == true) )  && (var.transit_gateway_peering.london_n_paris == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.london }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "eu-west-3"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-paris[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-london[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-london-n-paris" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.paris == true && var.deploy_transit_gateway_in_this_aws_region.london == true) )  && (var.transit_gateway_peering.london_n_paris == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.paris
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-london-n-paris[0].transit_gateway_peering_attachment_id
}


# PEERING : LONDON WITH FRANKFURT
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : LONDON
# ACCEPTOR : FRANKFURT
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-london-n-frankfurt" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.frankfurt == true && var.deploy_transit_gateway_in_this_aws_region.london == true) )  && (var.transit_gateway_peering.london_n_frankfurt == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.london }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "eu-central-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-frankfurt[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-london[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-london-n-frankfurt" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.frankfurt == true && var.deploy_transit_gateway_in_this_aws_region.london == true) )  && (var.transit_gateway_peering.london_n_frankfurt == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.frankfurt
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-london-n-frankfurt[0].transit_gateway_peering_attachment_id
}


# PEERING : LONDON WITH STOCKHOLM
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : LONDON
# ACCEPTOR : STOCKHOLM
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-london-n-stockholm" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.stockholm == true && var.deploy_transit_gateway_in_this_aws_region.london == true) )  && (var.transit_gateway_peering.london_n_stockholm == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.london }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "eu-north-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-stockholm[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-london[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-london-n-stockholm" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.stockholm == true && var.deploy_transit_gateway_in_this_aws_region.london == true) )  && (var.transit_gateway_peering.london_n_stockholm == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.stockholm
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-london-n-stockholm[0].transit_gateway_peering_attachment_id
}


# PEERING : IRELAND WITH PARIS
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : IRELAND
# ACCEPTOR : PARIS
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-ireland-n-paris" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.paris == true && var.deploy_transit_gateway_in_this_aws_region.ireland == true) )  && (var.transit_gateway_peering.ireland_n_paris == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.ireland }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "eu-west-3"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-paris[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-ireland[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-ireland-n-paris" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.paris == true && var.deploy_transit_gateway_in_this_aws_region.ireland == true) )  && (var.transit_gateway_peering.ireland_n_paris == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.paris
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-ireland-n-paris[0].transit_gateway_peering_attachment_id
}


# PEERING : IRELAND WITH FRANKFURT
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : IRELAND
# ACCEPTOR : FRANKFURT
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-ireland-n-frankfurt" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.frankfurt == true && var.deploy_transit_gateway_in_this_aws_region.ireland == true) )  && (var.transit_gateway_peering.ireland_n_frankfurt == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.ireland }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "eu-central-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-frankfurt[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-ireland[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-ireland-n-frankfurt" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.frankfurt == true && var.deploy_transit_gateway_in_this_aws_region.ireland == true) )  && (var.transit_gateway_peering.ireland_n_frankfurt == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.frankfurt
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-ireland-n-frankfurt[0].transit_gateway_peering_attachment_id
}


# PEERING : IRELAND WITH STOCKHOLM
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : IRELAND
# ACCEPTOR : STOCKHOLM
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-ireland-n-stockholm" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.stockholm == true && var.deploy_transit_gateway_in_this_aws_region.ireland == true) )  && (var.transit_gateway_peering.london_n_stockholm == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.ireland }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "eu-north-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-stockholm[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-ireland[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-ireland-n-stockholm" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.stockholm == true && var.deploy_transit_gateway_in_this_aws_region.ireland == true) )  && (var.transit_gateway_peering.ireland_n_stockholm == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.stockholm
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-ireland-n-stockholm[0].transit_gateway_peering_attachment_id
}


# PEERING : FRANKFURT WITH STOCKHOLM
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : FRANKFURT
# ACCEPTOR : STOCKHOLM
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-frankfurt-n-stockholm" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.frankfurt == true && var.deploy_transit_gateway_in_this_aws_region.stockholm == true) )  && (var.transit_gateway_peering.frankfurt_n_stockholm == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.frankfurt }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "eu-north-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-stockholm[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-frankfurt[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-frankfurt-n-stockholm" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.frankfurt == true && var.deploy_transit_gateway_in_this_aws_region.stockholm == true) )  && (var.transit_gateway_peering.frankfurt_n_stockholm == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.stockholm
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-frankfurt-n-stockholm[0].transit_gateway_peering_attachment_id
}


# PEERING : FRANKFURT WITH PARIS
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : FRANKFURT
# ACCEPTOR : PARIS
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-frankfurt-n-paris" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.frankfurt == true && var.deploy_transit_gateway_in_this_aws_region.paris == true) )  && (var.transit_gateway_peering.frankfurt_n_paris == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.frankfurt }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "eu-west-3"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-paris[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-frankfurt[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-frankfurt-n-paris" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.frankfurt == true && var.deploy_transit_gateway_in_this_aws_region.paris == true) )  && (var.transit_gateway_peering.frankfurt_n_paris == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.paris
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-frankfurt-n-paris[0].transit_gateway_peering_attachment_id
}


# PEERING : STOCKHOLM WITH PARIS
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : STOCKHOLM
# ACCEPTOR : PARIS
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-stockholm-n-paris" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.stockholm == true && var.deploy_transit_gateway_in_this_aws_region.paris == true) )  && (var.transit_gateway_peering.stockholm_n_paris == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.stockholm }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "eu-west-3"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-paris[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-stockholm[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-stockholm-n-paris" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.stockholm == true && var.deploy_transit_gateway_in_this_aws_region.paris == true) )  && (var.transit_gateway_peering.stockholm_n_paris == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.paris
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-stockholm-n-paris[0].transit_gateway_peering_attachment_id
}


############################## ASIA ##############################

# PEERING : MUMBAI WITH FRANKFURT
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : MUMBAI
# ACCEPTOR : FRANKFURT
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-mumbai-n-frankfurt" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.frankfurt == true && var.deploy_transit_gateway_in_this_aws_region.mumbai == true) )  && (var.transit_gateway_peering.mumbai_n_frankfurt == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.mumbai }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "eu-central-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-frankfurt[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-mumbai[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-mumbai-n-frankfurt" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.frankfurt == true && var.deploy_transit_gateway_in_this_aws_region.mumbai == true) )  && (var.transit_gateway_peering.mumbai_n_frankfurt == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.frankfurt
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-mumbai-n-frankfurt[0].transit_gateway_peering_attachment_id
}


# PEERING : MUMBAI WITH SAO PAULO
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : MUMBAI
# ACCEPTOR : SAO PAULO
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-mumbai-n-sao-paulo" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true && var.deploy_transit_gateway_in_this_aws_region.mumbai == true) )  && (var.transit_gateway_peering.mumbai_n_sao_paulo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.mumbai }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "sa-east-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-sao-paulo[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-mumbai[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-mumbai-n-sao-paulo" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true && var.deploy_transit_gateway_in_this_aws_region.mumbai == true) )  && (var.transit_gateway_peering.mumbai_n_sao_paulo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.sao_paulo
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-mumbai-n-sao-paulo[0].transit_gateway_peering_attachment_id
}


# PEERING : MUMBAI WITH TOKYO
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : MUMBAI
# ACCEPTOR : TOKYO
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-mumbai-n-tokyo" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.tokyo == true && var.deploy_transit_gateway_in_this_aws_region.mumbai == true) )  && (var.transit_gateway_peering.mumbai_n_tokyo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.mumbai }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "ap-northeast-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-tokyo[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-mumbai[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-mumbai-n-tokyo" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.tokyo == true && var.deploy_transit_gateway_in_this_aws_region.mumbai == true) )  && (var.transit_gateway_peering.mumbai_n_tokyo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.tokyo
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-mumbai-n-tokyo[0].transit_gateway_peering_attachment_id
}



# PEERING : MUMBAI WITH SEOUL
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : MUMBAI
# ACCEPTOR : SEOUL
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-mumbai-n-seoul" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.seoul == true && var.deploy_transit_gateway_in_this_aws_region.mumbai == true) )  && (var.transit_gateway_peering.mumbai_n_seoul == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.mumbai }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "ap-northeast-2"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-seoul[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-mumbai[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-mumbai-n-seoul" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.seoul == true && var.deploy_transit_gateway_in_this_aws_region.mumbai == true) )  && (var.transit_gateway_peering.mumbai_n_seoul == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.seoul
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-mumbai-n-seoul[0].transit_gateway_peering_attachment_id
}


# PEERING : MUMBAI WITH SINGAPORE
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : MUMBAI
# ACCEPTOR : SINGAPORE
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-mumbai-n-singapore" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.singapore == true && var.deploy_transit_gateway_in_this_aws_region.mumbai == true) )  && (var.transit_gateway_peering.mumbai_n_singapore == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.mumbai }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "ap-southeast-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-singapore[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-mumbai[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-mumbai-n-singapore" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.singapore == true && var.deploy_transit_gateway_in_this_aws_region.mumbai == true) )  && (var.transit_gateway_peering.mumbai_n_singapore == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.singapore
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-mumbai-n-singapore[0].transit_gateway_peering_attachment_id
}


# PEERING : MUMBAI WITH SYDNEY
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : MUMBAI
# ACCEPTOR : SYDNEY
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-mumbai-n-sydney" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sydney == true && var.deploy_transit_gateway_in_this_aws_region.mumbai == true) )  && (var.transit_gateway_peering.mumbai_n_sydney == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.mumbai }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "ap-southeast-2"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-sydney[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-mumbai[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-mumbai-n-sydney" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sydney == true && var.deploy_transit_gateway_in_this_aws_region.mumbai == true) )  && (var.transit_gateway_peering.mumbai_n_sydney == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.sydney
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-mumbai-n-sydney[0].transit_gateway_peering_attachment_id
}



# PEERING : SINGAPORE WITH SYDNEY
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : SINGAPORE
# ACCEPTOR : SYDNEY
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-singapore-n-sydney" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sydney == true && var.deploy_transit_gateway_in_this_aws_region.singapore == true) )  && (var.transit_gateway_peering.singapore_n_sydney == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.singapore }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "ap-southeast-2"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-sydney[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-singapore[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-singapore-n-sydney" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sydney == true && var.deploy_transit_gateway_in_this_aws_region.singapore == true) )  && (var.transit_gateway_peering.singapore_n_sydney == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.sydney
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-singapore-n-sydney[0].transit_gateway_peering_attachment_id
}



# PEERING : SINGAPORE WITH TOKYO
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : SINGAPORE
# ACCEPTOR : TOKYO
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-singapore-n-tokyo" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.tokyo == true && var.deploy_transit_gateway_in_this_aws_region.singapore == true) )  && (var.transit_gateway_peering.singapore_n_tokyo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.singapore }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "ap-northeast-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-tokyo[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-singapore[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-singapore-n-tokyo" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.tokyo == true && var.deploy_transit_gateway_in_this_aws_region.singapore == true) )  && (var.transit_gateway_peering.singapore_n_tokyo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.tokyo
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-singapore-n-tokyo[0].transit_gateway_peering_attachment_id
}



# PEERING : SINGAPORE WITH SEOUL
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : SINGAPORE
# ACCEPTOR : SEOUL
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-singapore-n-seoul" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.seoul == true && var.deploy_transit_gateway_in_this_aws_region.singapore == true) )  && (var.transit_gateway_peering.singapore_n_seoul == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.singapore }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "ap-northeast-2"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-seoul[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-singapore[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-singapore-n-seoul" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.seoul == true && var.deploy_transit_gateway_in_this_aws_region.singapore == true) )  && (var.transit_gateway_peering.singapore_n_seoul == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.seoul
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-singapore-n-seoul[0].transit_gateway_peering_attachment_id
}



# -----


# PEERING : SYDNEY WITH TOKYO
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : SYDNEY
# ACCEPTOR : TOKYO
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-sydney-n-tokyo" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.tokyo == true && var.deploy_transit_gateway_in_this_aws_region.sydney == true) )  && (var.transit_gateway_peering.sydney_n_tokyo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.sydney }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "ap-northeast-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-tokyo[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-sydney[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-sydney-n-tokyo" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.tokyo == true && var.deploy_transit_gateway_in_this_aws_region.sydney == true) )  && (var.transit_gateway_peering.sydney_n_tokyo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.tokyo
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-sydney-n-tokyo[0].transit_gateway_peering_attachment_id
}


# PEERING : SYDNEY WITH SEOUL
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : SINGAPORE
# ACCEPTOR : SYDNEY
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-sydney-n-seoul" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.seoul == true && var.deploy_transit_gateway_in_this_aws_region.sydney == true) )  && (var.transit_gateway_peering.sydney_n_seoul == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.sydney }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "ap-northeast-2"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-seoul[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-sydney[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-sydney-n-seoul" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.seoul == true && var.deploy_transit_gateway_in_this_aws_region.sydney == true) )  && (var.transit_gateway_peering.sydney_n_seoul == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.seoul
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-sydney-n-seoul[0].transit_gateway_peering_attachment_id
}



# PEERING : TOKYO WITH SEOUL
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : TOKYO
# ACCEPTOR : SEOUL
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-tokyo-n-seoul" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.seoul == true && var.deploy_transit_gateway_in_this_aws_region.tokyo == true) )  && (var.transit_gateway_peering.tokyo_n_seoul == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.tokyo }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "ap-northeast-2"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-seoul[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-tokyo[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-tokyo-n-seoul" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.seoul == true && var.deploy_transit_gateway_in_this_aws_region.tokyo == true) )  && (var.transit_gateway_peering.tokyo_n_seoul == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.seoul
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-tokyo-n-seoul[0].transit_gateway_peering_attachment_id
}


# PEERING : TOKYO WITH SAO PAULO
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : TOKYO
# ACCEPTOR : SAO PAULO
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-tokyo-n-sao-paulo" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true && var.deploy_transit_gateway_in_this_aws_region.tokyo == true) )  && (var.transit_gateway_peering.tokyo_n_sao_paulo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.tokyo }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "sa-east-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-sao-paulo[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-tokyo[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-tokyo-n-sao-paulo" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true && var.deploy_transit_gateway_in_this_aws_region.tokyo == true) )  && (var.transit_gateway_peering.tokyo_n_sao_paulo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.sao_paulo
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-tokyo-n-sao-paulo[0].transit_gateway_peering_attachment_id
}


# PEERING : SYDNEY WITH SAO PAULO
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : SINGAPORE
# ACCEPTOR : SAO PAULO
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-sydney-n-sao-paulo" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true && var.deploy_transit_gateway_in_this_aws_region.sydney == true) )  && (var.transit_gateway_peering.sydney_n_sao_paulo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.sydney }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "sa-east-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-sao-paulo[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-sydney[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-sydney-n-sao-paulo" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true && var.deploy_transit_gateway_in_this_aws_region.sydney == true) )  && (var.transit_gateway_peering.sydney_n_sao_paulo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.sao_paulo
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-sydney-n-sao-paulo[0].transit_gateway_peering_attachment_id
}


# PEERING : SINGAPORE WITH SAO PAULO
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : SINGAPORE
# ACCEPTOR : SAO PAULO
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-singapore-n-sao-paulo" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true && var.deploy_transit_gateway_in_this_aws_region.singapore == true) )  && (var.transit_gateway_peering.singapore_n_sao_paulo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.singapore }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "sa-east-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-sao-paulo[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-singapore[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-singapore-n-sao-paulo" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true && var.deploy_transit_gateway_in_this_aws_region.singapore == true) )  && (var.transit_gateway_peering.singapore_n_sao_paulo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.sao_paulo
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-singapore-n-sao-paulo[0].transit_gateway_peering_attachment_id
}

# PEERING : PARIS WITH SAO PAULO
#-----------------------------------------------------------------------------------------------------
# REQUESTER REGION : PARIS
# ACCEPTOR : SAO PAULO
#-----------------------------------------------------------------------------------------------------

//noinspection ConflictingProperties
module "terraform-aws-fsf-tgw-peering-regions-paris-n-sao-paulo" {
  source                = "./peer_transit_gateways"
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true && var.deploy_transit_gateway_in_this_aws_region.paris == true) )  && (var.transit_gateway_peering.paris_n_sao_paulo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  providers = { aws = aws.paris }
  # transit gateway being peered with account id
  peer_account_id         =  data.aws_caller_identity.first.account_id
  # transit gateway being peered with region
  peer_region             = "sa-east-1"
  # transit gateway being peered with
  peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-sao-paulo[0].transit_gateway_id
  # transit gateway requesting to be peered
  transit_gateway_id      = module.terraform-aws-fsf-tgw-deployment-paris[0].transit_gateway_id

  Application_ID      = var.Application_ID
  Application_Name    = var.Application_Name
  Business_Unit       = var.Business_Unit
  Environment_Type    = var.Environment_Type
  Supported_Networks  = var.Supported_Networks
  CostCenterCode      = var.CostCenterCode
  CreatedBy           = var.CreatedBy
  Manager             = var.Manager

}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "transit_gateway_peering_acceptance-paris-n-sao-paulo" {
  count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.sao-paulo == true && var.deploy_transit_gateway_in_this_aws_region.paris == true) )  && (var.transit_gateway_peering.paris_n_sao_paulo == true || var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
  provider = aws.sao_paulo
  transit_gateway_attachment_id = module.terraform-aws-fsf-tgw-peering-regions-paris-n-sao-paulo[0].transit_gateway_peering_attachment_id
}

