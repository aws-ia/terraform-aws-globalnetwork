# ---------------------------------------------------------------------------------------------------------------
# Allows the addition of validation to this terraform module.
# ---------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "first" {
  provider = aws.ohio
}

data "aws_partition" "aws_partition" {}

resource "aws_iam_role_policy" "lambda_tgw_globalnetwork_attach_policy" {
  count = (var.network_manager_deployment==true ? 1:0)
  name = "lambda_tgw_globalnetwork_attach_policy"
  role = aws_iam_role.iam_for_lambda_tgw_globalnetwork_attach[0].id

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
        "Action": ["networkmanager:RegisterTransitGateway"],
        "Resource": "arn:aws:networkmanager::${data.aws_caller_identity.first.account_id}:global-network/${var.network_manager_id}",
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
  count = (var.network_manager_deployment==true ? 1:0)
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
  count = (var.network_manager_deployment==true ? 1:0)
  filename      = data.archive_file.zip.output_path
  function_name = join("_", ["lambda-gn-tgw", random_uuid.uuid_lambda_spoke.result])
  role          = aws_iam_role.iam_for_lambda_tgw_globalnetwork_attach[0].arn
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
  providers = {aws = aws.n_virginia}

  create_site_to_site_vpn = var.create_site_to_site_vpn.n_virginia
  remote_site_public_ip = var.remote_site_public_ip.n_virginia # var.remote_site_public_ip.hq
  remote_site_asn = var.remote_site_asn.n_virginia             # var.remote_site_asn.hq
  amazon_side_asn = "64512" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.
  how_many_vpn_connections = var.how_many_vpn_connections.n_virginia

  enable_acceleration                               = var.enable_acceleration.n_virginia
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.n_virginia
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.n_virginia
  tunnel_inside_cidrs                               = var.tunnel_inside_cidrs.n_virginia

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.n_virginia
  default_route_table_propagation = var.default_route_table_propagation.n_virginia
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.n_virginia
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.n_virginia

  dns_support                     = var.dns_support.n_virginia
  vpn_ecmp_support                = var.vpn_ecmp_support.n_virginia

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  create_site_to_site_vpn                           = var.create_site_to_site_vpn.ohio
  remote_site_public_ip                             = var.remote_site_public_ip.ohio
  amazon_side_asn                                   = "64513" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.
  remote_site_asn                                   = var.remote_site_asn.ohio
  how_many_vpn_connections                          = var.how_many_vpn_connections.ohio

  enable_acceleration                               = var.enable_acceleration.ohio
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.ohio
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.ohio
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.ohio

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association                   = var.default_route_table_association.ohio
  default_route_table_propagation                   = var.default_route_table_propagation.ohio
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.ohio
  centralized_packet_inspection_enabled             = var.centralized_packet_inspection_enabled.ohio

  dns_support                                       = var.dns_support.ohio
  vpn_ecmp_support                                  = var.vpn_ecmp_support.ohio

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  how_many_vpn_connections = var.how_many_vpn_connections.n_california

  enable_acceleration                               = var.enable_acceleration.n_california
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.n_california
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.n_california
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.n_california

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.n_california
  default_route_table_propagation = var.default_route_table_propagation.n_california
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.n_california
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.n_california

  dns_support                     = var.dns_support.n_california
  vpn_ecmp_support                = var.vpn_ecmp_support.n_california

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  how_many_vpn_connections = var.how_many_vpn_connections.oregon

  enable_acceleration                               = var.enable_acceleration.oregon
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.oregon
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.oregon
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.oregon

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.oregon
  default_route_table_propagation = var.default_route_table_propagation.oregon
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.oregon
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.oregon

  dns_support                     = var.dns_support.oregon
  vpn_ecmp_support                = var.vpn_ecmp_support.oregon

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  how_many_vpn_connections = var.how_many_vpn_connections.canada_east

  enable_acceleration                               = var.enable_acceleration.canada_east
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.canada_east
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.canada_east
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.canada_east

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.canada_east
  default_route_table_propagation = var.default_route_table_propagation.canada_east
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.canada_east
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.canada_east

  dns_support                     = var.dns_support.canada_east
  vpn_ecmp_support                = var.vpn_ecmp_support.canada_east

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  how_many_vpn_connections = var.how_many_vpn_connections.mumbai

  enable_acceleration                               = var.enable_acceleration.mumbai
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.mumbai
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.mumbai
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.mumbai

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.mumbai
  default_route_table_propagation = var.default_route_table_propagation.mumbai
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.mumbai
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.mumbai

  dns_support                     = var.dns_support.mumbai
  vpn_ecmp_support                = var.vpn_ecmp_support.mumbai

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  how_many_vpn_connections = var.how_many_vpn_connections.seoul

  enable_acceleration                               = var.enable_acceleration.seoul
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.seoul
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.seoul
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.seoul

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.seoul
  default_route_table_propagation = var.default_route_table_propagation.seoul
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.seoul
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.seoul

  dns_support                     = var.dns_support.seoul
  vpn_ecmp_support                = var.vpn_ecmp_support.seoul

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  how_many_vpn_connections = var.how_many_vpn_connections.singapore

  enable_acceleration                               = var.enable_acceleration.singapore
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.singapore
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.singapore
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.singapore

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.singapore
  default_route_table_propagation = var.default_route_table_propagation.singapore
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.singapore
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.singapore

  dns_support                     = var.dns_support.singapore
  vpn_ecmp_support                = var.vpn_ecmp_support.singapore

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  how_many_vpn_connections = var.how_many_vpn_connections.sydney

  enable_acceleration                               = var.enable_acceleration.sydney
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.sydney
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.sydney
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.sydney

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.sydney
  default_route_table_propagation = var.default_route_table_propagation.sydney
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.sydney
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.sydney

  dns_support                     = var.dns_support.sydney
  vpn_ecmp_support                = var.vpn_ecmp_support.sydney

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  how_many_vpn_connections = var.how_many_vpn_connections.tokyo

  enable_acceleration                               = var.enable_acceleration.tokyo
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.tokyo
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.tokyo
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.tokyo

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.tokyo
  default_route_table_propagation = var.default_route_table_propagation.tokyo
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.tokyo
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.tokyo

  dns_support                     = var.dns_support.tokyo
  vpn_ecmp_support                = var.vpn_ecmp_support.tokyo

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  how_many_vpn_connections = var.how_many_vpn_connections.frankfurt

  enable_acceleration                               = var.enable_acceleration.frankfurt
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.frankfurt
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.frankfurt
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.frankfurt

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.frankfurt
  default_route_table_propagation = var.default_route_table_propagation.frankfurt
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.frankfurt
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.frankfurt

  dns_support                     = var.dns_support.frankfurt
  vpn_ecmp_support                = var.vpn_ecmp_support.frankfurt

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  how_many_vpn_connections = var.how_many_vpn_connections.ireland

  enable_acceleration                               = var.enable_acceleration.ireland
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.ireland
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.ireland
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.ireland

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.ireland
  default_route_table_propagation = var.default_route_table_propagation.ireland
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.ireland
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.ireland

  dns_support                     = var.dns_support.ireland
  vpn_ecmp_support                = var.vpn_ecmp_support.ireland

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  how_many_vpn_connections = var.how_many_vpn_connections.london

  enable_acceleration                               = var.enable_acceleration.london
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.london
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.london
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.london

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.london
  default_route_table_propagation = var.default_route_table_propagation.london
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.london
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.london

  dns_support                     = var.dns_support.london
  vpn_ecmp_support                = var.vpn_ecmp_support.london

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  how_many_vpn_connections = var.how_many_vpn_connections.paris

  enable_acceleration                               = var.enable_acceleration.paris
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.paris
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.paris
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.paris

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.paris
  default_route_table_propagation = var.default_route_table_propagation.paris
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.paris
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.paris

  dns_support                     = var.dns_support.paris
  vpn_ecmp_support                = var.vpn_ecmp_support.paris

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  how_many_vpn_connections = var.how_many_vpn_connections.stockholm

  enable_acceleration                               = var.enable_acceleration.stockholm
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.stockholm
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.stockholm
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.stockholm

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.stockholm
  default_route_table_propagation = var.default_route_table_propagation.stockholm
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.stockholm
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.stockholm

  dns_support                     = var.dns_support.stockholm
  vpn_ecmp_support                = var.vpn_ecmp_support.stockholm

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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
  how_many_vpn_connections = var.how_many_vpn_connections.sao-paulo

  enable_acceleration                               = var.enable_acceleration.sao_paulo
  tunnel1_preshared_key                             = var.tunnel1_preshared_key.sao-paulo
  tunnel2_preshared_key                             = var.tunnel2_preshared_key.sao-paulo
  tunnel_inside_cidrs                                = var.tunnel_inside_cidrs.sao-paulo

  tunnel_inside_ip_version                          = var.tunnel_inside_ip_version
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

  default_route_table_association = var.default_route_table_association.sao_paulo
  default_route_table_propagation = var.default_route_table_propagation.sao_paulo
  enable_integration_with_network_deployer_solution = var.enable_integration_with_network_deployer_solution.sao_paulo
  centralized_packet_inspection_enabled = var.centralized_packet_inspection_enabled.sao_paulo

  dns_support                     = var.dns_support.sao_paulo
  vpn_ecmp_support                = var.vpn_ecmp_support.sao_paulo

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
  function_name = aws_lambda_function.lambda_globalnetwork_tgw_attach[0].function_name
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

