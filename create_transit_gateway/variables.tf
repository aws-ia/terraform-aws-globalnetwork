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
#  AWS Transit Gateway | ---> Enables the deployment of a transit gateway in the specified region
#-----------------------------------------------------------------------------------------------------
variable "transit_gateway_deployment" {
  default = true
  validation {
    condition     = (var.transit_gateway_deployment == false || var.transit_gateway_deployment == true)
    error_message = "Transit Gateway deployment must be either true or false."
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
  validation {
    condition     = (var.auto_accept_shared_attachments == "enable")
    error_message = "Auto acceptance of attachments must be enabled."
  }
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
# ---------------------------------------------------------------------------------------------------------------

variable "create_site_to_site_vpn" {
  default = true
  validation {
    condition     = (var.create_site_to_site_vpn == false || var.create_site_to_site_vpn == true)
    error_message = "Create site to site VPN must be either true or false."
  }
}

variable "remote_site_asn" { 
    default = 65000
    }

variable "remote_site_public_ip"{
    default = "127.0.0.1"
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
  default = "fsf-transit-gateway"
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


variable "deploy_transit_gateway_in_this_aws_region" {
  type = map(bool)
  default = {
    ohio          = true
    n_virginia    = true
    oregon        = true
    n_california  = true
    canada_east   = true
    ireland       = true
    london        = true
    stockholm     = true
    frankfurt     = true
    paris         = true
    tokyo         = true
    seoul         = true
    sydney        = true
    mumbai        = true
    singapore     = true
    sao-paulo     = true
  }
}