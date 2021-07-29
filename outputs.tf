# -----------------------------------------------------------------------------------------------------
# Account Number 
# -----------------------------------------------------------------------------------------------------
output "transit_gateway_owner_id" {
  value = data.aws_caller_identity.first.account_id 
  # module.terraform-aws-fsf-tgw-deployment-n_virginia.transit_gateway_owner_id
}

//output "network_manager_id"{
//  value = data.aws_cloudformation_stack.network-manager-id.outputs["GlobalNetworkId"]
//
//}
# -----------------------------------------------------------------------------------------------------
# AWS Transit Gateway ID per AWS Region 
# -----------------------------------------------------------------------------------------------------

output "n_virginia_transit_gateway_id"{
  value = concat(module.terraform-aws-fsf-tgw-deployment-n_virginia.*.transit_gateway_id, [null])[0]

}

output "ohio_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-ohio.*.transit_gateway_id, [null])[0]
}

output "canada_montreal_transit_gateway_id"{
  value = concat(module.terraform-aws-fsf-tgw-deployment-canada-montreal.*.transit_gateway_id, [null])[0]
}

output "source_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-ohio.*.transit_gateway_id, [null])[0]
}

output "oregon_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-oregon.*.transit_gateway_id, [null])[0]
}

output "n_california_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-n_california.*.transit_gateway_id, [null])[0]
}

output "paris_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-paris.*.transit_gateway_id, [null])[0]
}

output "ireland_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-ireland.*.transit_gateway_id, [null])[0]
}

output "london_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-london.*.transit_gateway_id, [null])[0]
}

output "frankfurt_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-frankfurt.*.transit_gateway_id, [null])[0]
}

output "stockholm_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-stockholm.*.transit_gateway_id, [null])[0]
}

output "tokyo_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-tokyo.*.transit_gateway_id, [null])[0]
}

output "singapore_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-singapore.*.transit_gateway_id, [null])[0]
}

output "seoul_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-seoul.*.transit_gateway_id, [null])[0]
}

output "sydney_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-sydney.*.transit_gateway_id, [null])[0]
}

output "mumbai_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-mumbai.*.transit_gateway_id, [null])[0]
}

output "sao_paulo_transit_gateway_id"{
  value =  concat(module.terraform-aws-fsf-tgw-deployment-sao-paulo.*.transit_gateway_id, [null])[0]
}

# -----------------------------------------------------------------------------------------------------
# AWS Route Table ID per AWS Region 
# -----------------------------------------------------------------------------------------------------

# AWS Northern Virginia Region 
# -----------------------------------------------------------------------------------------------------
output "n_virginia_tgw_shared_services_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-n_virginia.*.shared_services_route_table_id, [null])[0]
}

output "n_virginia_tgw_north_south_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-n_virginia.*.north_south_route_table_id, [null])[0]
}

output "n_virginia_tgw_packet_inspection_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-n_virginia.*.packet_inspection_route_table_id, [null])[0]
}

output "n_virginia_tgw_development_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-n_virginia.*.development_route_table_id, [null])[0]
}

output "n_virginia_tgw_production_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-n_virginia.*.production_route_table_id, [null])[0]
}

output "n_virginia_tgw_uat_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-n_virginia.*.uat_route_table_id, [null])[0]
}


# AWS Ohio Region 
# -----------------------------------------------------------------------------------------------------
output "ohio_tgw_shared_services_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-ohio.*.shared_services_route_table_id, [null])[0]
}

output "ohio_tgw_north_south_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-ohio.*.north_south_route_table_id, [null])[0]
}

output "ohio_tgw_packet_inspection_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-ohio.*.packet_inspection_route_table_id, [null])[0]
}

output "ohio_tgw_development_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-ohio.*.development_route_table_id, [null])[0]
}

output "ohio_tgw_production_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-ohio.*.production_route_table_id, [null])[0]
}

output "ohio_tgw_uat_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-ohio.*.uat_route_table_id, [null])[0]
}

# AWS Canada-Montreal Region 
# -----------------------------------------------------------------------------------------------------
output "canada-montreal_tgw_shared_services_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-canada-montreal.*.shared_services_route_table_id, [null])[0]
}

output "canada-montreal_tgw_north_south_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-canada-montreal.*.north_south_route_table_id, [null])[0]
}

output "canada-montreal_tgw_packet_inspection_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-canada-montreal.*.packet_inspection_route_table_id, [null])[0]
}

output "canada-montreal_tgw_development_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-canada-montreal.*.development_route_table_id, [null])[0]
}

output "canada-montreal_tgw_production_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-canada-montreal.*.production_route_table_id, [null])[0]
}

output "canada-montreal_tgw_uat_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-canada-montreal.*.uat_route_table_id, [null])[0]
}


# AWS Northern California Region 
# -----------------------------------------------------------------------------------------------------
output "n_california_tgw_shared_services_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-n_california.*.shared_services_route_table_id, [null])[0]
# concat(, [null])[0]
}

output "n_california_tgw_north_south_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-n_california.*.north_south_route_table_id, [null])[0]
}

output "n_california_tgw_packet_inspection_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-n_california.*.packet_inspection_route_table_id, [null])[0]
}

output "n_california_tgw_development_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-n_california.*.development_route_table_id, [null])[0]
}

output "n_california_tgw_production_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-n_california.*.production_route_table_id, [null])[0]
}

output "n_california_tgw_uat_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-n_california.*.uat_route_table_id, [null])[0]
}

# AWS Oregon Region 
# -----------------------------------------------------------------------------------------------------

output "oregon_tgw_shared_services_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-oregon.*.shared_services_route_table_id, [null])[0]
  # concat(, [null])[0]
}

output "oregon_tgw_north_south_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-oregon.*.north_south_route_table_id, [null])[0]
}

output "oregon_tgw_packet_inspection_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-oregon.*.packet_inspection_route_table_id, [null])[0]
}

output "oregon_tgw_development_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-oregon.*.development_route_table_id, [null])[0]
}

output "oregon_tgw_production_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-oregon.*.production_route_table_id, [null])[0]
}

output "oregon_tgw_uat_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-oregon.*.uat_route_table_id, [null])[0]
}


# AWS Ireland Region 
# -----------------------------------------------------------------------------------------------------

output "ireland_tgw_shared_services_route_table_id" {
  value =  concat( module.terraform-aws-fsf-tgw-deployment-ireland.*.shared_services_route_table_id, [null])[0]
}

output "ireland_tgw_north_south_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-ireland.*.north_south_route_table_id, [null])[0]
}

output "ireland_tgw_packet_inspection_route_table_id" {
  value =  concat(module.terraform-aws-fsf-tgw-deployment-ireland.*.packet_inspection_route_table_id, [null])[0]
}

output "ireland_tgw_development_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-ireland.*.development_route_table_id, [null])[0]
}

output "ireland_tgw_production_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-ireland.*.production_route_table_id, [null])[0]
}

output "ireland_tgw_uat_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-ireland.*.uat_route_table_id, [null])[0]
}

# AWS London Region 
# -----------------------------------------------------------------------------------------------------
output "london_tgw_shared_services_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-london.*.shared_services_route_table_id, [null])[0]
}

output "london_tgw_north_south_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-london.*.north_south_route_table_id, [null])[0]
}

output "london_tgw_packet_inspection_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-london.*.packet_inspection_route_table_id, [null])[0]
}

output "london_tgw_development_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-london.*.development_route_table_id, [null])[0]
}

output "london_tgw_production_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-london.*.production_route_table_id, [null])[0]
}

output "london_tgw_uat_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-london.*.uat_route_table_id, [null])[0]
}

# AWS Frankfurt Region 
# -----------------------------------------------------------------------------------------------------
output "frankfurt_tgw_shared_services_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-frankfurt.*.shared_services_route_table_id, [null])[0]
}

output "frankfurt_tgw_north_south_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-frankfurt.*.north_south_route_table_id, [null])[0]
}

output "frankfurt_tgw_packet_inspection_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-frankfurt.*.packet_inspection_route_table_id, [null])[0]
}

output "frankfurt_tgw_development_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-frankfurt.*.development_route_table_id, [null])[0]
}

output "frankfurt_tgw_production_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-frankfurt.*.production_route_table_id, [null])[0]
}

output "frankfurt_tgw_uat_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-frankfurt.*.uat_route_table_id, [null])[0]
}

# AWS Paris Region 
# -----------------------------------------------------------------------------------------------------
output "paris_tgw_shared_services_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-paris.*.shared_services_route_table_id, [null])[0]
}

output "paris_tgw_north_south_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-paris.*.north_south_route_table_id, [null])[0]
}

output "paris_tgw_packet_inspection_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-paris.*.packet_inspection_route_table_id, [null])[0]
}

output "paris_tgw_development_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-paris.*.development_route_table_id, [null])[0]
}

output "paris_tgw_production_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-paris.*.production_route_table_id, [null])[0]
}

output "paris_tgw_uat_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-paris.*.uat_route_table_id, [null])[0]
}

# AWS Stockholm Region 
# -----------------------------------------------------------------------------------------------------
output "stockholm_tgw_shared_services_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-stockholm.*.shared_services_route_table_id, [null])[0]
}

output "stockholm_tgw_north_south_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-stockholm.*.north_south_route_table_id, [null])[0]
}

output "stockholm_tgw_packet_inspection_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-stockholm.*.packet_inspection_route_table_id, [null])[0]
}

output "stockholm_tgw_development_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-stockholm.*.development_route_table_id, [null])[0]
}

output "stockholm_tgw_production_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-stockholm.*.production_route_table_id, [null])[0]
}

output "stockholm_tgw_uat_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-stockholm.*.uat_route_table_id, [null])[0]
}

# AWS SAO PAULO Region 
# -----------------------------------------------------------------------------------------------------
output "sao-paulo_tgw_shared_services_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-sao-paulo.*.shared_services_route_table_id, [null])[0]
}

output "sao-paulo_tgw_north_south_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-sao-paulo.*.north_south_route_table_id, [null])[0]
}

output "sao-paulo_tgw_packet_inspection_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-sao-paulo.*.packet_inspection_route_table_id, [null])[0]
}

output "sao-paulo_tgw_development_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-sao-paulo.*.development_route_table_id, [null])[0]
}

output "sao-paulo_tgw_production_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-sao-paulo.*.production_route_table_id, [null])[0]
}

output "sao-paulo_tgw_uat_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-sao-paulo.*.uat_route_table_id, [null])[0]
}

# AWS Tokyo Region 
# -----------------------------------------------------------------------------------------------------
output "tokyo_tgw_shared_services_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-tokyo.*.shared_services_route_table_id, [null])[0]
}

output "tokyo_tgw_north_south_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-tokyo.*.north_south_route_table_id, [null])[0]
}

output "tokyo_tgw_packet_inspection_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-tokyo.*.packet_inspection_route_table_id, [null])[0]
}

output "tokyo_tgw_development_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-tokyo.*.development_route_table_id, [null])[0]
}

output "tokyo_tgw_production_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-tokyo.*.production_route_table_id, [null])[0]
}

output "tokyo_tgw_uat_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-tokyo.*.uat_route_table_id, [null])[0]
}


# AWS Singapore Region
# -----------------------------------------------------------------------------------------------------
output "singapore_tgw_shared_services_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-singapore.*.shared_services_route_table_id, [null])[0]
}

output "singapore_tgw_north_south_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-singapore.*.north_south_route_table_id, [null])[0]
}

output "singapore_tgw_packet_inspection_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-singapore.*.packet_inspection_route_table_id, [null])[0]
}

output "singapore_tgw_development_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-singapore.*.development_route_table_id, [null])[0]
}

output "singapore_tgw_production_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-singapore.*.production_route_table_id, [null])[0]
}

output "singapore_tgw_uat_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-singapore.*.uat_route_table_id, [null])[0]
}



# AWS Sydney Region
# -----------------------------------------------------------------------------------------------------
output "sydney_tgw_shared_services_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-sydney.*.shared_services_route_table_id, [null])[0]
}

output "sydney_tgw_north_south_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-sydney.*.north_south_route_table_id, [null])[0]
}

output "sydney_tgw_packet_inspection_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-sydney.*.packet_inspection_route_table_id, [null])[0]
}

output "sydney_tgw_development_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-sydney.*.development_route_table_id, [null])[0]
}

output "sydney_tgw_production_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-sydney.*.production_route_table_id, [null])[0]
}

output "sydney_tgw_uat_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-sydney.*.uat_route_table_id, [null])[0]
}


# AWS Mumbai Region
# -----------------------------------------------------------------------------------------------------
output "mumbai_tgw_shared_services_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-mumbai.*.shared_services_route_table_id, [null])[0]
}

output "mumbai_tgw_north_south_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-mumbai.*.north_south_route_table_id, [null])[0]
}

output "mumbai_tgw_packet_inspection_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-mumbai.*.packet_inspection_route_table_id, [null])[0]
}

output "mumbai_tgw_development_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-mumbai.*.development_route_table_id, [null])[0]
}

output "mumbai_tgw_production_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-mumbai.*.production_route_table_id, [null])[0]
}

output "mumbai_tgw_uat_route_table_id" {
  value = concat(module.terraform-aws-fsf-tgw-deployment-mumbai.*.uat_route_table_id, [null])[0]
}

# -----------------------------------------------------------------------------------------------------