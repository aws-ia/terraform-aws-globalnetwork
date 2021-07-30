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

variable "enable_integration_with_network_deployer_solution" {
  default = false
  validation {
    condition     = (var.enable_integration_with_network_deployer_solution == false || var.enable_integration_with_network_deployer_solution == true)
    error_message = "The variable enable_integration_with_network_deployer_solution can be either true or false."
  }
}

#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | ---> Manages VPN Attachment Association. True results in only the packet inspection table being populated with routes.
#-----------------------------------------------------------------------------------------------------
variable "centralized_packet_inspection_enabled" {
  default = false
  validation {
    condition     = (var.centralized_packet_inspection_enabled == false || var.centralized_packet_inspection_enabled == true)
    error_message = "The variable Centralized_packet_inspection_enabled can be either true or false."
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
    condition     = (var.vpn_ecmp_support == "enable" || var.vpn_ecmp_support == "disable" )
    error_message = "You have entered a value that is not accepted. This variable vpn_ecmp_support can either be enable or disable."
  }
}

variable "dns_support" {
  default = "disable"
  validation {
    condition     = (var.dns_support == "enable" || var.dns_support == "disable")
    error_message = "You have entered a value that is not accepted. This variable dns_support can either be enable or disable."
  }
}

variable "default_route_table_propagation" {
  default = "disable"
  validation {
    condition     = (var.default_route_table_propagation == "disable" || var.default_route_table_propagation == "enable")
    error_message = "Transit Gateway Attachments routes must not be automatically propagated to the default route table."
  }
}

variable "default_route_table_association" {
  default = "disable"
  validation {
    condition     = (var.default_route_table_association == "disable" || var.default_route_table_association == "enable")
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
# ----------------------------------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------------------------------
# Advance VPN Configuration
# -----------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------
# Indicate whether to enable acceleration for the VPN connection. Supports only EC2 Transit Gateway.
# -----------------------------------------------------------------------------------------------------
variable "enable_acceleration"{
  default = false
  validation {
    condition     = (var.enable_acceleration == true || var.enable_acceleration == false)
    error_message = "The variable enable_acceleration accepts true or false."
  }
}

# -----------------------------------------------------------------------------------------------------
# Indicate whether the VPN tunnels process IPv4 or IPv6 traffic. Valid values are ipv4 | ipv6.
# ipv6 Supports only EC2 Transit Gateway.
# -----------------------------------------------------------------------------------------------------
variable "tunnel_inside_ip_version" {
  default = "ipv4"
  validation {
    condition     = (var.tunnel_inside_ip_version == "ipv4" || var.tunnel_inside_ip_version == "ipv6" )
    error_message = "The variable tunnel_inside_ip_version accepts ipv4 or ipv6."
  }
}

# -----------------------------------------------------------------------------------------------------
# An array of possible inside tunnel cidrs. This array must have at least two  cidrs at any given time.
# -----------------------------------------------------------------------------------------------------
variable "tunnel_inside_cidrs"{
  default = []
}

variable "tunnel_cidrs"{
  default = [ "169.254.0.4/30", "169.254.0.8/30", "169.254.0.12/30", "169.254.0.16/30", "169.254.0.20/30",
    "169.254.0.24/30", "169.254.0.28/30", "169.254.0.32/30", "169.254.0.36/30", "169.254.0.40/30", "169.254.0.44/30",
    "169.254.0.48/30", "169.254.0.52/30", "169.254.0.56/30", "169.254.0.60/30", "169.254.0.64/30", "169.254.0.68/30",
    "169.254.0.72/30", "169.254.0.76/30", "169.254.0.80/30", "169.254.0.84/30", "169.254.0.88/30", "169.254.0.92/30",
    "169.254.0.96/30", "169.254.0.100/30", "169.254.0.104/30", "169.254.0.108/30", "169.254.0.112/30", "169.254.0.116/30",
    "169.254.0.120/30", "169.254.0.124/30", "169.254.0.128/30", "169.254.0.132/30", "169.254.0.136/30", "169.254.0.140/30",
    "169.254.0.144/30", "169.254.0.148/30", "169.254.0.152/30", "169.254.0.156/30", "169.254.0.160/30", "169.254.0.164/30",
    "169.254.0.168/30", "169.254.0.172/30", "169.254.0.176/30", "169.254.0.180/30", "169.254.0.184/30", "169.254.0.188/30",
    "169.254.0.192/30", "169.254.0.196/30", "169.254.0.200/30", "169.254.0.204/30", "169.254.0.208/30", "169.254.0.212/30",
    "169.254.0.216/30", "169.254.0.220/30", "169.254.0.224/30", "169.254.0.228/30", "169.254.0.232/30", "169.254.0.236/30",
    "169.254.0.240/30", "169.254.0.244/30", "169.254.0.248/30", "169.254.0.252/30"]
}

# -----------------------------------------------------------------------------------------------------
# The preshared key of the first VPN tunnel.
# The preshared key must be between 8 and 64 characters in length and cannot start with zero(0).
# Allowed characters are alphanumeric characters, periods(.) and underscores(_).
# -----------------------------------------------------------------------------------------------------
variable "tunnel1_preshared_key"{
  default = "babablacksheep"
}

# -----------------------------------------------------------------------------------------------------
# The preshared key of the second VPN tunnel.
# The preshared key must be between 8 and 64 characters in length and cannot start with zero(0).
# Allowed characters are alphanumeric characters, periods(.) and underscores(_).
# -----------------------------------------------------------------------------------------------------
variable "tunnel2_preshared_key"{
  default = "babablacksheep."
}


# -----------------------------------------------------------------------------------------------------
# The action to take after DPD timeout occurs for the first VPN tunnel.
# Specify restart to restart the IKE initiation.
# Specify clear to end the IKE session. Valid values are clear | none | restart.
# -----------------------------------------------------------------------------------------------------
variable "tunnel1_dpd_timeout_action"{
  default = "clear"
  validation {
    condition     = (var.tunnel1_dpd_timeout_action == "clear" || var.tunnel1_dpd_timeout_action == "none" || var.tunnel1_dpd_timeout_action == "restart" )
    error_message = "The variable tunnel1_dpd_timeout_action accepts clear, none or restart."
  }
}

# -----------------------------------------------------------------------------------------------------
# The action to take after DPD timeout occurs for the first VPN tunnel.
# Specify restart to restart the IKE initiation. Specify clear to end the IKE session.
# Valid values are clear | none | restart.
# -----------------------------------------------------------------------------------------------------
variable "tunnel2_dpd_timeout_action"{
  default = "clear"
  validation {
    condition     = (var.tunnel2_dpd_timeout_action == "clear" || var.tunnel2_dpd_timeout_action == "none" || var.tunnel2_dpd_timeout_action == "restart" )
    error_message = "The variable tunnel2_dpd_timeout_action accepts clear, none or restart."
  }
}

# -----------------------------------------------------------------------------------------------------
# The number of seconds after which a DPD timeout occurs for the first VPN tunnel.
# Valid value is equal or higher than 30.
# -----------------------------------------------------------------------------------------------------
variable "tunnel1_dpd_timeout_seconds"{
  default = 30
}

# The number of seconds after which a DPD timeout occurs for the second VPN tunnel.
# Valid value is equal or higher than 30.
variable "tunnel2_dpd_timeout_seconds"{
  default = 30
}

# The IKE versions that are permitted for the first VPN tunnel. Valid values are ikev1 | ikev2.
variable "tunnel1_ike_versions"{
  default = ["ikev1","ikev2"]
}

# The IKE versions that are permitted for the second VPN tunnel. Valid values are ikev1 | ikev2.
variable "tunnel2_ike_versions"{
  default = ["ikev1","ikev2"]
}


# List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 1 IKE negotiations.
# Valid values are 2 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24.
variable "tunnel1_phase1_dh_group_numbers"{
  default =  [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
}


# List of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 1 IKE negotiations.
# Valid values are 2 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24.
variable "tunnel2_phase1_dh_group_numbers"{
  default =  [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
}


# List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations.
# Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16.
variable "tunnel1_phase1_encryption_algorithms"{
  default = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
}


# List of one or more encryption algorithms that are permitted for the second VPN tunnel for phase 1 IKE negotiations.
# Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16.
variable "tunnel2_phase1_encryption_algorithms"{
  default = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
}

# One or more integrity algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations.
# Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512.

variable "tunnel1_phase1_integrity_algorithms"{
  default = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
}

# One or more integrity algorithms that are permitted for the second VPN tunnel for phase 1 IKE negotiations.
# Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512.
variable "tunnel2_phase1_integrity_algorithms"{
  default = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
}


# The lifetime for phase 1 of the IKE negotiation for the first VPN tunnel, in seconds.
# Valid value is between 900 and 28800.
variable "tunnel1_phase1_lifetime_seconds"{
  default = 28800
}

# The lifetime for phase 1 of the IKE negotiation for the second VPN tunnel, in seconds.
# Valid value is between 900 and 28800.
variable "tunnel2_phase1_lifetime_seconds"{
  default = 28800
}


# List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 2 IKE negotiations.
# Valid values are 2 | 5 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24.
variable "tunnel1_phase2_dh_group_numbers"{
  default = [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
}

# List of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 2 IKE negotiations.
# Valid values are 2 | 5 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24.

variable "tunnel2_phase2_dh_group_numbers"{
  default = [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
}

# List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations.
# Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16.
variable "tunnel1_phase2_encryption_algorithms"{
  default = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
}

# List of one or more encryption algorithms that are permitted for the second VPN tunnel for phase 2 IKE negotiations
# Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16.
variable "tunnel2_phase2_encryption_algorithms"{
  default = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
}

# List of one or more integrity algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations.
# Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512.
variable "tunnel1_phase2_integrity_algorithms"{
  default = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
}

# List of one or more integrity algorithms that are permitted for the second VPN tunnel for phase 2 IKE negotiations.
# Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512.
variable "tunnel2_phase2_integrity_algorithms"{
  default = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
}

# The lifetime for phase 2 of the IKE negotiation for the first VPN tunnel, in seconds.
# Valid value is between 900 and 3600.
variable "tunnel1_phase2_lifetime_seconds"{
  default = 3600
}

# The lifetime for phase 2 of the IKE negotiation for the second VPN tunnel, in seconds.
# Valid value is between 900 and 3600.
variable "tunnel2_phase2_lifetime_seconds"{
  default = 3600
}


# The percentage of the rekey window for the first VPN tunnel (determined by tunnel1_rekey_margin_time_seconds)
# during which the rekey time is randomly selected. Valid value is between 0 and 100.
variable "tunnel1_rekey_fuzz_percentage"{
  default = 100
}

# The percentage of the rekey window for the second VPN tunnel (determined by tunnel2_rekey_margin_time_seconds)
# during which the rekey time is randomly selected. Valid value is between 0 and 100.
variable "tunnel2_rekey_fuzz_percentage"{
  default = 100
}
# The margin time, in seconds, before the phase 2 lifetime expires, during which the AWS side of the first VPN connection performs an IKE rekey.
# The exact time of the rekey is randomly selected based on the value for tunnel1_rekey_fuzz_percentage. Valid value is between 60 and half of tunnel1_phase2_lifetime_seconds.
variable "tunnel1_rekey_margin_time_seconds"{
  default = 540
}

# The margin time, in seconds, before the phase 2 lifetime expires, during which the AWS side of the second VPN connection performs an IKE rekey.
# The exact time of the rekey is randomly selected based on the value for tunnel2_rekey_fuzz_percentage. Valid value is between 60 and half of tunnel2_phase2_lifetime_seconds.
variable "tunnel2_rekey_margin_time_seconds"{
  default = 540
}

# The number of packets in an IKE replay window for the first VPN tunnel. Valid value is between 64 and 2048.
variable "tunnel1_replay_window_size"{
  default = 1024
}

# The number of packets in an IKE replay window for the second VPN tunnel. Valid value is between 64 and 2048.
variable "tunnel2_replay_window_size"{
  default = 1024
}


# The action to take when the establishing the tunnel for the first VPN connection.
# By default, your customer gateway device must initiate the IKE negotiation and bring up the tunnel.
# Specify start for AWS to initiate the IKE negotiation. Valid values are add | start.
variable "tunnel1_startup_action"{
  default = "add"
  validation {
    condition     = (var.tunnel1_startup_action == "add" || var.tunnel1_startup_action == "start")
    error_message = "The variable tunnel1_startup_action accepts add or start."
  }
}

# The action to take when the establishing the tunnel for the second VPN connection.
# By default, your customer gateway device must initiate the IKE negotiation and bring up the tunnel.
# Specify start for AWS to initiate the IKE negotiation. Valid values are add | start.
variable "tunnel2_startup_action"{
  default = "add"
  validation {
    condition     = (var.tunnel2_startup_action == "add" || var.tunnel2_startup_action == "start")
    error_message = "The variable tunnel2_startup_action accepts add or start."
  }
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