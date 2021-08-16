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

variable "shuffle"{
  default = true
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
  default = [
    "169.254.0.4/30", "169.254.0.8/30", "169.254.0.12/30", "169.254.0.16/30", "169.254.0.20/30",
    "169.254.0.24/30", "169.254.0.28/30", "169.254.0.32/30", "169.254.0.36/30", "169.254.0.40/30", "169.254.0.44/30",
    "169.254.0.48/30", "169.254.0.52/30", "169.254.0.56/30", "169.254.0.60/30", "169.254.0.64/30", "169.254.0.68/30",
    "169.254.0.72/30", "169.254.0.76/30", "169.254.0.80/30", "169.254.0.84/30", "169.254.0.88/30", "169.254.0.92/30",
    "169.254.0.96/30", "169.254.0.100/30", "169.254.0.104/30", "169.254.0.108/30", "169.254.0.112/30", "169.254.0.116/30",
    "169.254.0.120/30", "169.254.0.124/30", "169.254.0.128/30", "169.254.0.132/30", "169.254.0.136/30", "169.254.0.140/30",
    "169.254.0.144/30", "169.254.0.148/30", "169.254.0.152/30", "169.254.0.156/30", "169.254.0.160/30", "169.254.0.164/30",
    "169.254.0.168/30", "169.254.0.172/30", "169.254.0.176/30", "169.254.0.180/30", "169.254.0.184/30", "169.254.0.188/30",
    "169.254.0.192/30", "169.254.0.196/30", "169.254.0.200/30", "169.254.0.204/30", "169.254.0.208/30", "169.254.0.212/30",
    "169.254.0.216/30", "169.254.0.220/30", "169.254.0.224/30", "169.254.0.228/30", "169.254.0.232/30", "169.254.0.236/30",
    "169.254.0.240/30", "169.254.0.244/30", "169.254.0.248/30", "169.254.0.252/30", "169.254.1.4/30", "169.254.1.8/30",
    "169.254.1.12/30", "169.254.1.16/30", "169.254.1.20/30", "169.254.1.24/30", "169.254.1.28/30", "169.254.1.32/30",
    "169.254.1.36/30", "169.254.1.40/30", "169.254.1.44/30", "169.254.1.48/30", "169.254.1.52/30", "169.254.1.56/30",
    "169.254.1.60/30", "169.254.1.64/30", "169.254.1.68/30",
    "169.254.1.72/30", "169.254.1.76/30", "169.254.1.80/30", "169.254.1.84/30", "169.254.1.88/30", "169.254.1.92/30",
    "169.254.1.96/30", "169.254.1.100/30", "169.254.1.104/30", "169.254.1.108/30", "169.254.1.112/30", "169.254.1.116/30",
    "169.254.1.120/30", "169.254.1.124/30", "169.254.1.128/30", "169.254.1.132/30", "169.254.1.136/30", "169.254.1.140/30",
    "169.254.1.144/30", "169.254.1.148/30", "169.254.1.152/30", "169.254.1.156/30", "169.254.1.160/30", "169.254.1.164/30",
    "169.254.1.168/30", "169.254.1.172/30", "169.254.1.176/30", "169.254.1.180/30", "169.254.1.184/30", "169.254.1.188/30",
    "169.254.1.192/30", "169.254.1.196/30", "169.254.1.200/30", "169.254.1.204/30", "169.254.1.208/30", "169.254.1.212/30",
    "169.254.1.216/30", "169.254.1.220/30", "169.254.1.224/30", "169.254.1.228/30", "169.254.1.232/30", "169.254.1.236/30",
    "169.254.1.240/30", "169.254.1.244/30", "169.254.1.248/30", "169.254.1.252/30", "169.254.2.4/30", "169.254.2.8/30",
    "169.254.2.12/30", "169.254.2.16/30", "169.254.2.20/30",
    "169.254.2.24/30", "169.254.2.28/30", "169.254.2.32/30", "169.254.2.36/30", "169.254.2.40/30", "169.254.2.44/30",
    "169.254.2.48/30", "169.254.2.52/30", "169.254.2.56/30", "169.254.2.60/30", "169.254.2.64/30", "169.254.2.68/30",
    "169.254.2.72/30", "169.254.2.76/30", "169.254.2.80/30", "169.254.2.84/30", "169.254.2.88/30", "169.254.2.92/30",
    "169.254.2.96/30", "169.254.2.100/30", "169.254.2.104/30", "169.254.2.108/30", "169.254.2.112/30", "169.254.2.116/30",
    "169.254.2.120/30", "169.254.2.124/30", "169.254.2.128/30", "169.254.2.132/30", "169.254.2.136/30", "169.254.2.140/30",
    "169.254.2.144/30", "169.254.2.148/30", "169.254.2.152/30", "169.254.2.156/30", "169.254.2.160/30", "169.254.2.164/30",
    "169.254.2.168/30", "169.254.2.172/30", "169.254.2.176/30", "169.254.2.180/30", "169.254.2.184/30", "169.254.2.188/30",
    "169.254.2.192/30", "169.254.2.196/30", "169.254.2.200/30", "169.254.2.204/30", "169.254.2.208/30", "169.254.2.212/30",
    "169.254.2.216/30", "169.254.2.220/30", "169.254.2.224/30", "169.254.2.228/30", "169.254.2.232/30", "169.254.2.236/30",
    "169.254.2.240/30", "169.254.2.244/30", "169.254.2.248/30", "169.254.2.252/30", "169.254.3.4/30", "169.254.3.8/30",
    "169.254.3.12/30", "169.254.3.16/30", "169.254.3.20/30",
    "169.254.3.24/30", "169.254.3.28/30", "169.254.3.32/30", "169.254.3.36/30", "169.254.3.40/30", "169.254.3.44/30",
    "169.254.3.48/30", "169.254.3.52/30", "169.254.3.56/30", "169.254.3.60/30", "169.254.3.64/30", "169.254.3.68/30",
    "169.254.3.72/30", "169.254.3.76/30", "169.254.3.80/30", "169.254.3.84/30", "169.254.3.88/30", "169.254.3.92/30",
    "169.254.3.96/30", "169.254.3.100/30", "169.254.3.104/30", "169.254.3.108/30", "169.254.3.112/30", "169.254.3.116/30",
    "169.254.3.120/30", "169.254.3.124/30", "169.254.3.128/30", "169.254.3.132/30", "169.254.3.136/30", "169.254.3.140/30",
    "169.254.3.144/30", "169.254.3.148/30", "169.254.3.152/30", "169.254.3.156/30", "169.254.3.160/30", "169.254.3.164/30",
    "169.254.3.168/30", "169.254.3.172/30", "169.254.3.176/30", "169.254.3.180/30", "169.254.3.184/30", "169.254.3.188/30",
    "169.254.3.192/30", "169.254.3.196/30", "169.254.3.200/30", "169.254.3.204/30", "169.254.3.208/30", "169.254.3.212/30",
    "169.254.3.216/30", "169.254.3.220/30", "169.254.3.224/30", "169.254.3.228/30", "169.254.3.232/30", "169.254.3.236/30",
    "169.254.3.240/30", "169.254.3.244/30", "169.254.3.248/30", "169.254.3.252/30", "169.254.4.4/30", "169.254.4.8/30",
    "169.254.4.12/30", "169.254.4.16/30", "169.254.4.20/30",
    "169.254.4.24/30", "169.254.4.28/30", "169.254.4.32/30", "169.254.4.36/30", "169.254.4.40/30", "169.254.4.44/30",
    "169.254.4.48/30", "169.254.4.52/30", "169.254.4.56/30", "169.254.4.60/30", "169.254.4.64/30", "169.254.4.68/30",
    "169.254.4.72/30", "169.254.4.76/30", "169.254.4.80/30", "169.254.4.84/30", "169.254.4.88/30", "169.254.4.92/30",
    "169.254.4.96/30", "169.254.4.100/30", "169.254.4.104/30", "169.254.4.108/30", "169.254.4.112/30", "169.254.4.116/30",
    "169.254.4.120/30", "169.254.4.124/30", "169.254.4.128/30", "169.254.4.132/30", "169.254.4.136/30", "169.254.4.140/30",
    "169.254.4.144/30", "169.254.4.148/30", "169.254.4.152/30", "169.254.4.156/30", "169.254.4.160/30", "169.254.4.164/30",
    "169.254.4.168/30", "169.254.4.172/30", "169.254.4.176/30", "169.254.4.180/30", "169.254.4.184/30", "169.254.4.188/30",
    "169.254.4.192/30", "169.254.4.196/30", "169.254.4.200/30", "169.254.4.204/30", "169.254.4.208/30", "169.254.4.212/30",
    "169.254.4.216/30", "169.254.4.220/30", "169.254.4.224/30", "169.254.4.228/30", "169.254.4.232/30", "169.254.4.236/30",
    "169.254.4.240/30", "169.254.4.244/30", "169.254.4.248/30", "169.254.4.252/30","169.254.5.4/30", "169.254.5.8/30",
    "169.254.5.12/30", "169.254.5.16/30", "169.254.5.20/30",
    "169.254.5.24/30", "169.254.5.28/30", "169.254.5.32/30", "169.254.5.36/30", "169.254.5.40/30", "169.254.5.44/30",
    "169.254.5.48/30", "169.254.5.52/30", "169.254.5.56/30", "169.254.5.60/30", "169.254.5.64/30", "169.254.5.68/30",
    "169.254.5.72/30", "169.254.5.76/30", "169.254.5.80/30", "169.254.5.84/30", "169.254.5.88/30", "169.254.5.92/30",
    "169.254.5.96/30", "169.254.5.100/30", "169.254.5.104/30", "169.254.5.108/30", "169.254.5.112/30", "169.254.5.116/30",
    "169.254.5.120/30", "169.254.5.124/30", "169.254.5.128/30", "169.254.5.132/30", "169.254.5.136/30", "169.254.5.140/30",
    "169.254.5.144/30", "169.254.5.148/30", "169.254.5.152/30", "169.254.5.156/30", "169.254.5.160/30", "169.254.5.164/30",
    "169.254.5.168/30", "169.254.5.172/30", "169.254.5.176/30", "169.254.5.180/30", "169.254.5.184/30", "169.254.5.188/30",
    "169.254.5.192/30", "169.254.5.196/30", "169.254.5.200/30", "169.254.5.204/30", "169.254.5.208/30", "169.254.5.212/30",
    "169.254.5.216/30", "169.254.5.220/30", "169.254.5.224/30", "169.254.5.228/30", "169.254.5.232/30", "169.254.5.236/30",
    "169.254.5.240/30", "169.254.5.244/30", "169.254.5.248/30", "169.254.5.252/30", "169.254.6.4/30", "169.254.6.8/30",
    "169.254.6.12/30", "169.254.6.16/30", "169.254.6.20/30",
    "169.254.6.24/30", "169.254.6.28/30", "169.254.6.32/30", "169.254.6.36/30", "169.254.6.40/30", "169.254.6.44/30",
    "169.254.6.48/30", "169.254.6.52/30", "169.254.6.56/30", "169.254.6.60/30", "169.254.6.64/30", "169.254.6.68/30",
    "169.254.6.72/30", "169.254.6.76/30", "169.254.6.80/30", "169.254.6.84/30", "169.254.6.88/30", "169.254.6.92/30",
    "169.254.6.96/30", "169.254.6.100/30", "169.254.6.104/30", "169.254.6.108/30", "169.254.6.112/30", "169.254.6.116/30",
    "169.254.6.120/30", "169.254.6.124/30", "169.254.6.128/30", "169.254.6.132/30", "169.254.6.136/30", "169.254.6.140/30",
    "169.254.6.144/30", "169.254.6.148/30", "169.254.6.152/30", "169.254.6.156/30", "169.254.6.160/30", "169.254.6.164/30",
    "169.254.6.168/30", "169.254.6.172/30", "169.254.6.176/30", "169.254.6.180/30", "169.254.6.184/30", "169.254.6.188/30",
    "169.254.6.192/30", "169.254.6.196/30", "169.254.6.200/30", "169.254.6.204/30", "169.254.6.208/30", "169.254.6.212/30",
    "169.254.6.216/30", "169.254.6.220/30", "169.254.6.224/30", "169.254.6.228/30", "169.254.6.232/30", "169.254.6.236/30",
    "169.254.6.240/30", "169.254.6.244/30", "169.254.6.248/30", "169.254.6.252/30", "169.254.7.4/30", "169.254.7.8/30",
    "169.254.7.12/30", "169.254.7.16/30", "169.254.7.20/30",
    "169.254.7.24/30", "169.254.7.28/30", "169.254.7.32/30", "169.254.7.36/30", "169.254.7.40/30", "169.254.7.44/30",
    "169.254.7.48/30", "169.254.7.52/30", "169.254.7.56/30", "169.254.7.60/30", "169.254.7.64/30", "169.254.7.68/30",
    "169.254.7.72/30", "169.254.7.76/30", "169.254.7.80/30", "169.254.7.84/30", "169.254.7.88/30", "169.254.7.92/30",
    "169.254.7.96/30", "169.254.7.100/30", "169.254.7.104/30", "169.254.7.108/30", "169.254.7.112/30", "169.254.7.116/30",
    "169.254.7.120/30", "169.254.7.124/30", "169.254.7.128/30", "169.254.7.132/30", "169.254.7.136/30", "169.254.7.140/30",
    "169.254.7.144/30", "169.254.7.148/30", "169.254.7.152/30", "169.254.7.156/30", "169.254.7.160/30", "169.254.7.164/30",
    "169.254.7.168/30", "169.254.7.172/30", "169.254.7.176/30", "169.254.7.180/30", "169.254.7.184/30", "169.254.7.188/30",
    "169.254.7.192/30", "169.254.7.196/30", "169.254.7.200/30", "169.254.7.204/30", "169.254.7.208/30", "169.254.7.212/30",
    "169.254.7.216/30", "169.254.7.220/30", "169.254.7.224/30", "169.254.7.228/30", "169.254.7.232/30", "169.254.7.236/30",
    "169.254.7.240/30", "169.254.7.244/30", "169.254.7.248/30", "169.254.7.252/30", "169.254.8.4/30", "169.254.8.8/30",
    "169.254.8.12/30", "169.254.8.16/30", "169.254.8.20/30",
    "169.254.8.24/30", "169.254.8.28/30", "169.254.8.32/30", "169.254.8.36/30", "169.254.8.40/30", "169.254.8.44/30",
    "169.254.8.48/30", "169.254.8.52/30", "169.254.8.56/30", "169.254.8.60/30", "169.254.8.64/30", "169.254.8.68/30",
    "169.254.8.72/30", "169.254.8.76/30", "169.254.8.80/30", "169.254.8.84/30", "169.254.8.88/30", "169.254.8.92/30",
    "169.254.8.96/30", "169.254.8.100/30", "169.254.8.104/30", "169.254.8.108/30", "169.254.8.112/30", "169.254.8.116/30",
    "169.254.8.120/30", "169.254.8.124/30", "169.254.8.128/30", "169.254.8.132/30", "169.254.8.136/30", "169.254.8.140/30",
    "169.254.8.144/30", "169.254.8.148/30", "169.254.8.152/30", "169.254.8.156/30", "169.254.8.160/30", "169.254.8.164/30",
    "169.254.8.168/30", "169.254.8.172/30", "169.254.8.176/30", "169.254.8.180/30", "169.254.8.184/30", "169.254.8.188/30",
    "169.254.8.192/30", "169.254.8.196/30", "169.254.8.200/30", "169.254.8.204/30", "169.254.8.208/30", "169.254.8.212/30",
    "169.254.8.216/30", "169.254.8.220/30", "169.254.8.224/30", "169.254.8.228/30", "169.254.8.232/30", "169.254.8.236/30",
    "169.254.8.240/30", "169.254.8.244/30", "169.254.8.248/30", "169.254.8.252/30", "169.254.9.4/30", "169.254.9.8/30",
    "169.254.9.12/30", "169.254.9.16/30", "169.254.9.20/30",
    "169.254.9.24/30", "169.254.9.28/30", "169.254.9.32/30", "169.254.9.36/30", "169.254.9.40/30", "169.254.9.44/30",
    "169.254.9.48/30", "169.254.9.52/30", "169.254.9.56/30", "169.254.9.60/30", "169.254.9.64/30", "169.254.9.68/30",
    "169.254.9.72/30", "169.254.9.76/30", "169.254.9.80/30", "169.254.9.84/30", "169.254.9.88/30", "169.254.9.92/30",
    "169.254.9.96/30", "169.254.9.100/30", "169.254.9.104/30", "169.254.9.108/30", "169.254.9.112/30", "169.254.9.116/30",
    "169.254.9.120/30", "169.254.9.124/30", "169.254.9.128/30", "169.254.9.132/30", "169.254.9.136/30", "169.254.9.140/30",
    "169.254.9.144/30", "169.254.9.148/30", "169.254.9.152/30", "169.254.9.156/30", "169.254.9.160/30", "169.254.9.164/30",
    "169.254.9.168/30", "169.254.9.172/30", "169.254.9.176/30", "169.254.9.180/30", "169.254.9.184/30", "169.254.9.188/30",
    "169.254.9.192/30", "169.254.9.196/30", "169.254.9.200/30", "169.254.9.204/30", "169.254.9.208/30", "169.254.9.212/30",
    "169.254.9.216/30", "169.254.9.220/30", "169.254.9.224/30", "169.254.9.228/30", "169.254.9.232/30", "169.254.9.236/30",
    "169.254.9.240/30", "169.254.9.244/30", "169.254.9.248/30", "169.254.9.252/30", "169.254.10.4/30", "169.254.10.8/30",
    "169.254.10.12/30", "169.254.10.16/30", "169.254.10.20/30",
    "169.254.10.24/30", "169.254.10.28/30", "169.254.10.32/30", "169.254.10.36/30", "169.254.10.40/30", "169.254.10.44/30",
    "169.254.10.48/30", "169.254.10.52/30", "169.254.10.56/30", "169.254.10.60/30", "169.254.10.64/30", "169.254.10.68/30",
    "169.254.10.72/30", "169.254.10.76/30", "169.254.10.80/30", "169.254.10.84/30", "169.254.10.88/30", "169.254.10.92/30",
    "169.254.10.96/30", "169.254.10.100/30", "169.254.10.104/30", "169.254.10.108/30", "169.254.10.112/30", "169.254.10.116/30",
    "169.254.10.120/30", "169.254.10.124/30", "169.254.10.128/30", "169.254.10.132/30", "169.254.10.136/30", "169.254.10.140/30",
    "169.254.10.144/30", "169.254.10.148/30", "169.254.10.152/30", "169.254.10.156/30", "169.254.10.160/30", "169.254.10.164/30",
    "169.254.10.168/30", "169.254.10.172/30", "169.254.10.176/30", "169.254.10.180/30", "169.254.10.184/30", "169.254.10.188/30",
    "169.254.10.192/30", "169.254.10.196/30", "169.254.10.200/30", "169.254.10.204/30", "169.254.10.208/30", "169.254.10.212/30",
    "169.254.10.216/30", "169.254.10.220/30", "169.254.10.224/30", "169.254.10.228/30", "169.254.10.232/30", "169.254.10.236/30",
    "169.254.10.240/30", "169.254.10.244/30", "169.254.10.248/30", "169.254.10.252/30", "169.254.11.4/30", "169.254.11.8/30",
    "169.254.11.12/30", "169.254.11.16/30", "169.254.11.20/30",
    "169.254.11.24/30", "169.254.11.28/30", "169.254.11.32/30", "169.254.11.36/30", "169.254.11.40/30", "169.254.11.44/30",
    "169.254.11.48/30", "169.254.11.52/30", "169.254.11.56/30", "169.254.11.60/30", "169.254.11.64/30", "169.254.11.68/30",
    "169.254.11.72/30", "169.254.11.76/30", "169.254.11.80/30", "169.254.11.84/30", "169.254.11.88/30", "169.254.11.92/30",
    "169.254.11.96/30", "169.254.11.100/30", "169.254.11.104/30", "169.254.11.108/30", "169.254.11.112/30", "169.254.11.116/30",
    "169.254.11.120/30", "169.254.11.124/30", "169.254.11.128/30", "169.254.11.132/30", "169.254.11.136/30", "169.254.11.140/30",
    "169.254.11.144/30", "169.254.11.148/30", "169.254.11.152/30", "169.254.11.156/30", "169.254.11.160/30", "169.254.11.164/30",
    "169.254.11.168/30", "169.254.11.172/30", "169.254.11.176/30", "169.254.11.180/30", "169.254.11.184/30", "169.254.11.188/30",
    "169.254.11.192/30", "169.254.11.196/30", "169.254.11.200/30", "169.254.11.204/30", "169.254.11.208/30", "169.254.11.212/30",
    "169.254.11.216/30", "169.254.11.220/30", "169.254.11.224/30", "169.254.11.228/30", "169.254.11.232/30", "169.254.11.236/30",
    "169.254.11.240/30", "169.254.11.244/30", "169.254.11.248/30", "169.254.11.252/30", "169.254.12.4/30", "169.254.12.8/30",
    "169.254.12.12/30", "169.254.12.16/30", "169.254.12.20/30",
    "169.254.12.24/30", "169.254.12.28/30", "169.254.12.32/30", "169.254.12.36/30", "169.254.12.40/30", "169.254.12.44/30",
    "169.254.12.48/30", "169.254.12.52/30", "169.254.12.56/30", "169.254.12.60/30", "169.254.12.64/30", "169.254.12.68/30",
    "169.254.12.72/30", "169.254.12.76/30", "169.254.12.80/30", "169.254.12.84/30", "169.254.12.88/30", "169.254.12.92/30",
    "169.254.12.96/30", "169.254.12.100/30", "169.254.12.104/30", "169.254.12.108/30", "169.254.12.112/30", "169.254.12.116/30",
    "169.254.12.120/30", "169.254.12.124/30", "169.254.12.128/30", "169.254.12.132/30", "169.254.12.136/30", "169.254.12.140/30",
    "169.254.12.144/30", "169.254.12.148/30", "169.254.12.152/30", "169.254.12.156/30", "169.254.12.160/30", "169.254.12.164/30",
    "169.254.12.168/30", "169.254.12.172/30", "169.254.12.176/30", "169.254.12.180/30", "169.254.12.184/30", "169.254.12.188/30",
    "169.254.12.192/30", "169.254.12.196/30", "169.254.12.200/30", "169.254.12.204/30", "169.254.12.208/30", "169.254.12.212/30",
    "169.254.12.216/30", "169.254.12.220/30", "169.254.12.224/30", "169.254.12.228/30", "169.254.12.232/30", "169.254.12.236/30",
    "169.254.12.240/30", "169.254.12.244/30", "169.254.12.248/30", "169.254.12.252/30", "169.254.13.4/30", "169.254.13.8/30",
    "169.254.13.12/30", "169.254.13.16/30", "169.254.13.20/30",
    "169.254.13.24/30", "169.254.13.28/30", "169.254.13.32/30", "169.254.13.36/30", "169.254.13.40/30", "169.254.13.44/30",
    "169.254.13.48/30", "169.254.13.52/30", "169.254.13.56/30", "169.254.13.60/30", "169.254.13.64/30", "169.254.13.68/30",
    "169.254.13.72/30", "169.254.13.76/30", "169.254.13.80/30", "169.254.13.84/30", "169.254.13.88/30", "169.254.13.92/30",
    "169.254.13.96/30", "169.254.13.100/30", "169.254.13.104/30", "169.254.13.108/30", "169.254.13.112/30", "169.254.13.116/30",
    "169.254.13.120/30", "169.254.13.124/30", "169.254.13.128/30", "169.254.13.132/30", "169.254.13.136/30", "169.254.13.140/30",
    "169.254.13.144/30", "169.254.13.148/30", "169.254.13.152/30", "169.254.13.156/30", "169.254.13.160/30", "169.254.13.164/30",
    "169.254.13.168/30", "169.254.13.172/30", "169.254.13.176/30", "169.254.13.180/30", "169.254.13.184/30", "169.254.13.188/30",
    "169.254.13.192/30", "169.254.13.196/30", "169.254.13.200/30", "169.254.13.204/30", "169.254.13.208/30", "169.254.13.212/30",
    "169.254.13.216/30", "169.254.13.220/30", "169.254.13.224/30", "169.254.13.228/30", "169.254.13.232/30", "169.254.13.236/30",
    "169.254.13.240/30", "169.254.13.244/30", "169.254.13.248/30", "169.254.13.252/30", "169.254.14.4/30", "169.254.14.8/30",
    "169.254.14.12/30", "169.254.14.16/30", "169.254.14.20/30",
    "169.254.14.24/30", "169.254.14.28/30", "169.254.14.32/30", "169.254.14.36/30", "169.254.14.40/30", "169.254.14.44/30",
    "169.254.14.48/30", "169.254.14.52/30", "169.254.14.56/30", "169.254.14.60/30", "169.254.14.64/30", "169.254.14.68/30",
    "169.254.14.72/30", "169.254.14.76/30", "169.254.14.80/30", "169.254.14.84/30", "169.254.14.88/30", "169.254.14.92/30",
    "169.254.14.96/30", "169.254.14.100/30", "169.254.14.104/30", "169.254.14.108/30", "169.254.14.112/30", "169.254.14.116/30",
    "169.254.14.120/30", "169.254.14.124/30", "169.254.14.128/30", "169.254.14.132/30", "169.254.14.136/30", "169.254.14.140/30",
    "169.254.14.144/30", "169.254.14.148/30", "169.254.14.152/30", "169.254.14.156/30", "169.254.14.160/30", "169.254.14.164/30",
    "169.254.14.168/30", "169.254.14.172/30", "169.254.14.176/30", "169.254.14.180/30", "169.254.14.184/30", "169.254.14.188/30",
    "169.254.14.192/30", "169.254.14.196/30", "169.254.14.200/30", "169.254.14.204/30", "169.254.14.208/30", "169.254.14.212/30",
    "169.254.14.216/30", "169.254.14.220/30", "169.254.14.224/30", "169.254.14.228/30", "169.254.14.232/30", "169.254.14.236/30",
    "169.254.14.240/30", "169.254.14.244/30", "169.254.14.248/30", "169.254.14.252/30", "169.254.15.4/30", "169.254.15.8/30", "169.254.15.12/30", "169.254.15.16/30", "169.254.15.20/30",
    "169.254.15.24/30", "169.254.15.28/30", "169.254.15.32/30", "169.254.15.36/30", "169.254.15.40/30", "169.254.15.44/30",
    "169.254.15.48/30", "169.254.15.52/30", "169.254.15.56/30", "169.254.15.60/30", "169.254.15.64/30", "169.254.15.68/30",
    "169.254.15.72/30", "169.254.15.76/30", "169.254.15.80/30", "169.254.15.84/30", "169.254.15.88/30", "169.254.15.92/30",
    "169.254.15.96/30", "169.254.15.100/30", "169.254.15.104/30", "169.254.15.108/30", "169.254.15.112/30", "169.254.15.116/30",
    "169.254.15.120/30", "169.254.15.124/30", "169.254.15.128/30", "169.254.15.132/30", "169.254.15.136/30", "169.254.15.140/30",
    "169.254.15.144/30", "169.254.15.148/30", "169.254.15.152/30", "169.254.15.156/30", "169.254.15.160/30", "169.254.15.164/30",
    "169.254.15.168/30", "169.254.15.172/30", "169.254.15.176/30", "169.254.15.180/30", "169.254.15.184/30", "169.254.15.188/30",
    "169.254.15.192/30", "169.254.15.196/30", "169.254.15.200/30", "169.254.15.204/30", "169.254.15.208/30", "169.254.15.212/30",
    "169.254.15.216/30", "169.254.15.220/30", "169.254.15.224/30", "169.254.15.228/30", "169.254.15.232/30", "169.254.15.236/30",
    "169.254.15.240/30", "169.254.15.244/30", "169.254.15.248/30", "169.254.15.252/30"
  ]
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