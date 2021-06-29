#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | ---> Create Network Manager
#-----------------------------------------------------------------------------------------------------
# This variables tells the solution if an AWS Network Manager exist (true) or not (false).
#-----------------------------------------------------------------------------------------------------
variable "network_manager_deployment" {
  default = false
  validation {
    condition     = (var.network_manager_deployment == false || var.network_manager_deployment == true)
    error_message = "AWS Network Manager deployment must be either true or false."
  }
}

#-----------------------------------------------------------------------------------------------------
# This variables holds the name an AWS Network Manager
#-----------------------------------------------------------------------------------------------------
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
#  AWS Transit Gateway | ---> AWS Site-to-Site
#-----------------------------------------------------------------------------------------------------
# This variables map tells the solution if it should create an AWS Site-to-Site VPN and which region
# Simply set true for the region in which you would like to deploy
#-----------------------------------------------------------------------------------------------------
variable "create_site_to_site_vpn" {
  type = map(bool)
  default = {
    ohio          = false
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

#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | --->  Create Transit Gateway
#-----------------------------------------------------------------------------------------------------
# This variable controls the creation of a transit gateway in the region to the left.
# Simply set true if you want to create or false if you dont want to create.
# The option "all_aws_region" allows you to create a transit gateway in all AWS Region.
# There's no need to specify true for individual regions if "all_aws_region" is set to true.
#-----------------------------------------------------------------------------------------------------
variable "deploy_transit_gateway_in_this_aws_region" {
  type = map(bool)
  default = {
    all_aws_regions                       = false # true
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

#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | --->  Create Transit Gateway Peering Connection
#-----------------------------------------------------------------------------------------------------
# This variable controls the creation of a transit gateway peering between transit gateways deployed in different AWS Regions.
# The option "build_complete_mesh" complements the "all_aws_region" in the variable "deploy_transit_gateway_in_this_aws_region"
# Set "build_complete_mesh" to true if you have set "all_aws_region" to true AND you would like to build a completely globally meshed transit gateway network.
#-----------------------------------------------------------------------------------------------------
variable "transit_gateway_peering" {
  type = map(bool)
  default = {
    build_complete_mesh           = false # true
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
  type = map(number)
    default = {
      hq                                    = 65000
      ohio                                  = 65000
      n_virginia                            = 65000
      oregon                                = 65000
      n_california                          = 65000
      canada_east                           = 65000
      ireland                               = 65000
      london                                = 65000
      stockholm                             = 65000
      frankfurt                             = 65000
      paris                                 = 65000
      tokyo                                 = 65000
      seoul                                 = 65000
      sydney                                = 65000
      mumbai                                = 65000
      singapore                             = 65000
      sao-paulo                             = 65000
    }
}


variable "remote_site_public_ip"{
    type = map(string)
    default = {
      hq                                    = "127.0.0.1"
      ohio                                  = "127.0.0.1"
      n_virginia                            = "127.0.0.1"
      oregon                                = "127.0.0.1"
      n_california                          = "127.0.0.1"
      canada_east                           = "127.0.0.1"
      ireland                               = "127.0.0.1"
      london                                = "127.0.0.1"
      stockholm                             = "127.0.0.1"
      frankfurt                             = "127.0.0.1"
      paris                                 = "127.0.0.1"
      tokyo                                 = "127.0.0.1"
      seoul                                 = "127.0.0.1"
      sydney                                = "127.0.0.1"
      mumbai                                = "127.0.0.1"
      singapore                             = "127.0.0.1"
      sao-paulo                             = "127.0.0.1"
  }
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

