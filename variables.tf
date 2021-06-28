
#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | ---> Create Network Manager
#-----------------------------------------------------------------------------------------------------
variable "network_manager_deployment" {
  default = true
  validation {
    condition     = (var.network_manager_deployment == false || var.network_manager_deployment == true)
    error_message = "AWS Network Manager deployment must be either true or false."
  }
}

variable "network_manager_name"{
  default = "transit-gateway-network-manager-stack"
}

# ----------------------------------------------------------------------------------------------------
# Please update this variable if you have an AWS Network Manager deployed.
# The full AWS ARN is required for your AWS Network Manager.
# ----------------------------------------------------------------------------------------------------
variable "network_manager_id"{
  default = "aws-network-manager-id"
}
# ----------------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | ---> Enables the creation of a specific transit gateway route table  
#-----------------------------------------------------------------------------------------------------
variable "route_tables" {
  type = map(bool)
  default = {
    shared_services_route_table   = true
    north_south_route_table       = true
    packet_inspection_route_table = true
    development_route_table       = true
    production_route_table        = true 
    uat_route_table               = true 
  }
}


#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | ---> Manages VPN Attachment Association.
#  True results in only the packet inspection table being populated with routes.
#  False results in the addition of on-premises routes added to the dev, uat, prod, shared services, and packet inspection transit gateway route table.
#-----------------------------------------------------------------------------------------------------
variable "centralized_packet_inspection_enabled" {
  default = false
  validation {
    condition     = (var.centralized_packet_inspection_enabled == false || var.centralized_packet_inspection_enabled == true)
    error_message = "Centralized_packet_inspection_enabled must be either true or false."
  }
}


#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | ---> Enables the deployment of a transit gateway in the specified region
#-----------------------------------------------------------------------------------------------------
variable "transit_gateway_deployment" {
  default = true
  validation {
    condition     = (var.transit_gateway_deployment == false || var.transit_gateway_deployment == true)
    error_message = "Transit Gateway deployment must be either true or false."
  }
}

variable "create_site_to_site_vpn" {
  type = map(bool)
  default = {
    ohio          = true
    n_virginia    = false
    oregon        = false
    n_california  = false
    canada_east   = false
    ireland       = false
    london        = false
    stockholm     = false
    frankfurt     = false
    paris         = false
    tokyo         = false
    seoul         = false
    sydney        = false
    mumbai        = false
    singapore     = false
    sao_paulo     = false
  }
}


variable "deploy_transit_gateway_in_this_aws_region" {
  type = map(bool)
  default = {
    all_aws_regions                       = true # false
    ohio                                  = false # true
    n_virginia                            = false # true
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

variable "transit_gateway_peering" {
  type = map(bool)
  default = {
    build_complete_mesh           = true # false
    ohio_n_virginia               = false # true
    ohio_canada_east              = false # true
    ohio_oregon                   = false # true
    ohio_n_california             = false # true
    oregon_n_california           = false # true
    oregon_canada_east            = false # true
    oregon_n_virginia             = false # true
    oregon_n_sao_paulo            = false # true
    oregon_n_london               = false # true
    # n_california_canada_east      = false # true
    n_california_n_virginia       = false # true
    n_virginia_canada_east        = false # true
    n_virginia_n_london           = false # true
    n_virginia_sao_paulo          = false # true
    london_n_ireland              = false # true
    london_n_paris                = false # true
    london_n_frankfurt            = false # true
    london_n_milan                = false # true
    london_n_stockholm            = false # true
    ireland_n_paris               = false # true
    ireland_n_frankfurt           = false # true
    ireland_n_stockholm           = false # true
    frankfurt_n_stockholm         = false # true
    frankfurt_n_paris             = false # true
    stockholm_n_paris             = false # true
    mumbai_n_frankfurt            = false # true
    mumbai_n_sao_paulo            = false # true
    mumbai_n_tokyo                = false # true
    mumbai_n_seoul                = false # true
    mumbai_n_singapore            = false # true
    mumbai_n_sydney               = false # true
    singapore_n_sydney            = false # true
    singapore_n_tokyo             = false # true
    singapore_n_sao_paulo         = false # true
    singapore_n_seoul             = false # true
    sydney_n_seoul                = false # true
    sydney_n_tokyo                = false # true
    sydney_n_sao_paulo            = false # true
    tokyo_n_seoul                 = false # true
    tokyo_n_sao_paulo             = false # true
    paris_n_sao_paulo             = false # true
  }
}

#-----------------------------------------------------------------------------------------------------
# AWS Transit Gateway | ---> Transit Gateway Configuration Parameter
#-----------------------------------------------------------------------------------------------------
variable amazon_side_asn{
    default="64512"
}

variable "vpn_ecmp_support" {
  default = "enable"
  validation {
    condition     = (var.vpn_ecmp_support == "enable")
    error_message = "External Principals should not be allowed unless in the case of a merger."
  }
}

variable "dns_support" {
  default = "disable"
}

variable "default_route_table_propagation" {
  default = "disable"
  validation {
    condition     = (var.default_route_table_propagation == "disable")
    error_message = "Transit Gateway Attachments routes must not be automatically propagated to the default route table."
  }
}

variable "default_route_table_association" {
  default = "disable"
  validation {
    condition     = (var.default_route_table_association == "disable")
    error_message = "Attachments must not be automatically associated with the TGW Default route table."
  }
}

variable "auto_accept_shared_attachments" {
  default = "enable"
}

variable "allow_external_principals" {
  default = false
  validation {
    condition     = (var.allow_external_principals == false)
    error_message = "External Principals should not be allowed unless in the case of a merger."
  }
}

variable "ram_share_name" {
  default = "shared_networking_resources"
}


#-----------------------------------------------------------------------------------------------------
# AWS Transit Gateway | ---> AWS Site-to-Site VPN Configuration
# -----------------------------------------------------------------------------------------------------
variable "tgw_vpn" {
  type = map(bool)
  default = { 
    create_site_to_site_vpn  = true 
    
  }
}

variable "remote_site_asn" { 
    default = 65000
    }

variable "remote_site_public_ip"{
    default = "127.0.0.0"
}    

variable "vpn_type"{
    default = "ipsec.1"
}

variable "how_many_vpn_connections"{
    default = 1
}

#-----------------------------------------------------------------------------------------------------
# Variables that makes up the AWS Tags assigned to the VPC on creation.
# ---------------------------------------------------------------------------------------------------------------

variable "Application_ID" {
  description = "The Application ID of the application that will be hosted inside this Amazon VPC."
  type = string
  default = "0000000"
}

variable "Application_Name" {
  description = "The name of the application. Max 10 characters. Allowed characters [0-9A-Za-z]."
  type = string
  default = "fsf-transit-gateway-vpc"
}

variable "Business_Unit" {
  description = "The business unit or line of business to which this application belongs."
  type = string
  default = "Commercial Banking (CB)"
}

variable "Environment_Type" {
  description = "The applications environment type. Possible values: LAB, SandBox, DEV, UAT, PROD."
  type = string
  default = "PRODUCTION"
  validation {
    condition     = (var.Environment_Type == "PRODUCTION")
    error_message = "External Principals should not be allowed unless in the case of a merger."
  }
}

variable "Supported_Networks" {
  description = "The applications environment type. Possible values: LAB, SandBox, DEV, UAT, PROD."
  type = string
  default = "Spoke_VPCs_Under_This_Organization"
  validation {
    condition     = (var.Supported_Networks == "Spoke_VPCs_Under_This_Organization")
    error_message = "External Principals should not be allowed unless in the case of a merger."
  }
}

variable "CostCenterCode" {
  description = "CSI Billing Profile Number associated with application to be hosted in this vpc."
  type = string
  default = "CB-0000000"
}

variable "CreatedBy" {
  description = "CSI Billing Profile Number associated with application to be hosted in this vpc."
  type = string
  default = "Androski_Spicer"
}

variable "Manager" {
  description = "CSI Billing Profile Number associated with application to be hosted in this vpc."
  type = string
  default = "KenJackson"
}