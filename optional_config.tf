//
//#-----------------------------------------------------------------------------------------------------
//#  AWS Transit Gateway | ---> Enables the creation of a specific transit gateway route table
//#-----------------------------------------------------------------------------------------------------
//variable "route_tables" {
//  type = map(bool)
//  default = {
//    shared_services_route_table   = true
//    north_south_route_table       = true
//    packet_inspection_route_table = true
//    development_route_table       = true
//    production_route_table        = true
//    uat_route_table               = true
//  }
//}


//#-----------------------------------------------------------------------------------------------------
//#  AWS Transit Gateway | ---> Enables the deployment of a transit gateway in the specified region
//#-----------------------------------------------------------------------------------------------------
//variable "transit_gateway_deployment" {
//  default = true
//  validation {
//    condition     = (var.transit_gateway_deployment == false || var.transit_gateway_deployment == true)
//    error_message = "Transit Gateway deployment must be either true or false."
//  }
//}
//


#-----------------------------------------------------------------------------------------------------
# AWS Transit Gateway | ---> Transit Gateway Configuration Parameter
#-----------------------------------------------------------------------------------------------------
//variable amazon_side_asn{
//    default="64512"
//}

//variable "vpn_ecmp_support" {
//  default = "enable"
//  validation {
//    condition     = (var.vpn_ecmp_support == "enable")
//    error_message = "External Principals should not be allowed unless in the case of a merger."
//  }
//}

//variable "dns_support" {
//  default = "disable"
//}

//variable "default_route_table_propagation" {
//  default = "disable"
//  validation {
//    condition     = (var.default_route_table_propagation == "disable")
//    error_message = "Transit Gateway Attachments routes must not be automatically propagated to the default route table."
//  }
//}

//variable "default_route_table_association" {
//  default = "disable"
//  validation {
//    condition     = (var.default_route_table_association == "disable")
//    error_message = "Attachments must not be automatically associated with the TGW Default route table."
//  }
//}

//variable "auto_accept_shared_attachments" {
//  default = "enable"
//}

//variable "allow_external_principals" {
//  default = false
//  validation {
//    condition     = (var.allow_external_principals == false)
//    error_message = "External Principals should not be allowed unless in the case of a merger."
//  }
//}


//variable "vpn_type"{
//    default = "ipsec.1"
//}

