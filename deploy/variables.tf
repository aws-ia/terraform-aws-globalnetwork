#-----------------------------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | ---> Creates AWS Transit Gateway route tables that are needed by the network deployer solution
#-----------------------------------------------------------------------------------------------------------------------
variable "enable_integration_with_network_deployer_solution" {
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

variable "default_route_table_propagation" {
  type = map(string)
  default = {
    hq                                    = "disable"
    ohio                                  = "disable"
    n_virginia                            = "disable"
    oregon                                = "disable"
    n_california                          = "disable"
    canada_east                           = "disable"
    ireland                               = "disable"
    london                                = "disable"
    stockholm                             = "disable"
    frankfurt                             = "disable"
    paris                                 = "disable"
    tokyo                                 = "disable"
    seoul                                 = "disable"
    sydney                                = "disable"
    mumbai                                = "disable"
    singapore                             = "disable"
    sao_paulo                             = "disable"
  }
}

variable "default_route_table_association" {
  type = map(string)
  default = {
    hq                                    = "disable"
    ohio                                  = "disable"
    n_virginia                            = "disable"
    oregon                                = "disable"
    n_california                          = "disable"
    canada_east                           = "disable"
    ireland                               = "disable"
    london                                = "disable"
    stockholm                             = "disable"
    frankfurt                             = "disable"
    paris                                 = "disable"
    tokyo                                 = "disable"
    seoul                                 = "disable"
    sydney                                = "disable"
    mumbai                                = "disable"
    singapore                             = "disable"
    sao_paulo                             = "disable"
  }
}

variable "vpn_ecmp_support" {
  type = map(string)
  default = {
    hq                                    = "enable"
    ohio                                  = "enable"
    n_virginia                            = "enable"
    oregon                                = "enable"
    n_california                          = "enable"
    canada_east                           = "enable"
    ireland                               = "enable"
    london                                = "enable"
    stockholm                             = "enable"
    frankfurt                             = "enable"
    paris                                 = "enable"
    tokyo                                 = "enable"
    seoul                                 = "enable"
    sydney                                = "enable"
    mumbai                                = "enable"
    singapore                             = "enable"
    sao_paulo                             = "enable"
  }
}

variable "dns_support" {
  type = map(string)
  default = {
    hq                                    = "disable"
    ohio                                  = "disable"
    n_virginia                            = "disable"
    oregon                                = "disable"
    n_california                          = "disable"
    canada_east                           = "disable"
    ireland                               = "disable"
    london                                = "disable"
    stockholm                             = "disable"
    frankfurt                             = "disable"
    paris                                 = "disable"
    tokyo                                 = "disable"
    seoul                                 = "disable"
    sydney                                = "disable"
    mumbai                                = "disable"
    singapore                             = "disable"
    sao_paulo                             = "disable"
  }
}


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
  default = "your-global-network-id-here"
}


#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | ---> Manages VPN Attachment Association.
#  True results in only the packet inspection table being populated with routes.
#  False results in the addition of on-premises routes added to the dev, uat, prod, shared services, and packet inspection transit gateway route table.
#-----------------------------------------------------------------------------------------------------
variable "centralized_packet_inspection_enabled" {
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
    # n_california_canada_east    = false # true
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
  type = map(number)
  default = {
    hq                                    = 0
    ohio                                  = 1
    n_virginia                            = 0
    oregon                                = 0
    n_california                          = 0
    canada_east                           = 0
    ireland                               = 0
    london                                = 0
    stockholm                             = 0
    frankfurt                             = 0
    paris                                 = 0
    tokyo                                 = 0
    seoul                                 = 0
    sydney                                = 0
    mumbai                                = 0
    singapore                             = 0
    sao-paulo                             = 0
  }
}



# -----------------------------------------------------------------------------------------------------
# Advance VPN Configuration
# -----------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------
# Indicate whether to enable acceleration for the VPN connection. Supports only EC2 Transit Gateway.
# -----------------------------------------------------------------------------------------------------
variable "enable_acceleration"{
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


variable "tunnel_inside_cidrs"{
  type = map(list(string))
  default = {
    ohio                                  = []
    n_virginia                            = []
    oregon                                = []
    n_california                          = []
    canada_east                           = []
    ireland                               = []
    london                                = []
    stockholm                             = []
    frankfurt                             = []
    paris                                 = []
    tokyo                                 = []
    seoul                                 = []
    sydney                                = []
    mumbai                                = []
    singapore                             = []
    sao-paulo                             = []
  }
}


# -----------------------------------------------------------------------------------------------------
# The preshared key of the first VPN tunnel.
# The preshared key must be between 8 and 64 characters in length and cannot start with zero(0).
# Allowed characters are alphanumeric characters, periods(.) and underscores(_).
# -----------------------------------------------------------------------------------------------------
variable "tunnel1_preshared_key"{
  type = map(string)
  default = {
    ohio                                  = ""
    n_virginia                            = ""
    oregon                                = ""
    n_california                          = ""
    canada_east                           = ""
    ireland                               = ""
    london                                = ""
    stockholm                             = ""
    frankfurt                             = ""
    paris                                 = ""
    tokyo                                 = ""
    seoul                                 = ""
    sydney                                = ""
    mumbai                                = ""
    singapore                             = ""
    sao-paulo                             = ""
  }
}


# -----------------------------------------------------------------------------------------------------
# The preshared key of the second VPN tunnel.
# The preshared key must be between 8 and 64 characters in length and cannot start with zero(0).
# Allowed characters are alphanumeric characters, periods(.) and underscores(_).
# -----------------------------------------------------------------------------------------------------
variable "tunnel2_preshared_key"{
  default = {
    ohio                                  = ""
    n_virginia                            = ""
    oregon                                = ""
    n_california                          = ""
    canada_east                           = ""
    ireland                               = ""
    london                                = ""
    stockholm                             = ""
    frankfurt                             = ""
    paris                                 = ""
    tokyo                                 = ""
    seoul                                 = ""
    sydney                                = ""
    mumbai                                = ""
    singapore                             = ""
    sao-paulo                             = ""
  }
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
  validation {
    condition     = (var.tunnel1_dpd_timeout_seconds>= 30)
    error_message = "Valid value is equal or higher than 30."
  }
}

# The number of seconds after which a DPD timeout occurs for the second VPN tunnel.
# Valid value is equal or higher than 30.
variable "tunnel2_dpd_timeout_seconds"{
  default = 30
  validation {
    condition     = (var.tunnel2_dpd_timeout_seconds>= 30)
    error_message = "Valid value is equal or higher than 30."
  }
}

# The IKE versions that are permitted for the first VPN tunnel. Valid values are ikev1 | ikev2.
variable "tunnel1_ike_versions"{
  default = ["ikev1","ikev2"]
  validation {
    condition     = alltrue([for o in var.tunnel1_ike_versions : contains(["ikev1","ikev2"], o)])
    error_message = "Valid value is equal to ikev1 or ikev2."
  }
}

# The IKE versions that are permitted for the second VPN tunnel. Valid values are ikev1 | ikev2.
variable "tunnel2_ike_versions"{
  default = ["ikev1","ikev2"]
  validation {
    condition     = alltrue([for o in var.tunnel2_ike_versions : contains(["ikev1","ikev2"], o)])
    error_message = "Valid value is equal to ikev1 or ikev2."
  }
}


# List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 1 IKE negotiations.
# Valid values are 2 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24.
variable "tunnel1_phase1_dh_group_numbers"{
  default =  [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
  validation {
    condition     = alltrue([for o in var.tunnel1_phase1_dh_group_numbers : contains([2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], o)])
    error_message = "Valid value is equal to 2 or 14 or 15 or 16 or 17 or 18 or 19 or 20 or 21 or 22 or 23 or 24."
  }
}


# List of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 1 IKE negotiations.
# Valid values are 2 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24.
variable "tunnel2_phase1_dh_group_numbers"{
  default =  [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
  validation {
    condition     = alltrue([for o in var.tunnel2_phase1_dh_group_numbers : contains([2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], o)])
    error_message = "Valid value is equal to 2 or 14 or 15 or 16 or 17 or 18 or 19 or 20 or 21 or 22 or 23 or 24."
  }
}


# List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations.
# Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16.
variable "tunnel1_phase1_encryption_algorithms"{
  default = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
  validation {
    condition     = alltrue([for o in var.tunnel1_phase1_encryption_algorithms : contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], o)])
    error_message = "Valid value is equal to 2 or 14 or 15 or 16 or 17 or 18 or 19 or 20 or 21 or 22 or 23 or 24."
  }
}


# List of one or more encryption algorithms that are permitted for the second VPN tunnel for phase 1 IKE negotiations.
# Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16.
variable "tunnel2_phase1_encryption_algorithms"{
  default = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
  validation {
    condition     = alltrue([for o in var.tunnel2_phase1_encryption_algorithms : contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], o)])
    error_message = "Valid value are AES128, AES256, AES128-GCM-16, AES256-GCM-16."
  }
}

# One or more integrity algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations.
# Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512.

variable "tunnel1_phase1_integrity_algorithms"{
  default = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
  validation {
    condition     = alltrue([for o in var.tunnel1_phase1_integrity_algorithms : contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], o)])
    error_message = "Valid value are SHA1, SHA2-256, SHA2-384, SHA2-512."
  }
}

# One or more integrity algorithms that are permitted for the second VPN tunnel for phase 1 IKE negotiations.
# Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512.
variable "tunnel2_phase1_integrity_algorithms"{
  default = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
  validation {
    condition     = alltrue([for o in var.tunnel2_phase1_integrity_algorithms : contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], o)])
    error_message = "Valid value are SHA1, SHA2-256, SHA2-384, SHA2-512."
  }
}


# The lifetime for phase 1 of the IKE negotiation for the first VPN tunnel, in seconds.
# Valid value is between 900 and 28800.
variable "tunnel1_phase1_lifetime_seconds"{
  default = 28800
  validation {
  condition     = (
    contains(range(900, 1024), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(1024, 2048), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(2048, 3072), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(3072, 4096), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(4096, 5120), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(5120, 6144), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(6144, 7168), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(7168, 8192), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(8192, 9216), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(9216, 10240), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(10240, 11264), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(11264, 12288), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(12288, 13312), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(13312, 14336), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(14336, 15360), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(15360, 16384), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(16384, 17408), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(17408, 18432), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(18432, 19456), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(19456, 20480), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(20480, 21504), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(21504, 22526), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(22526, 23550), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(23550, 24574), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(24574, 25598), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(25598, 26622), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(26622, 27646), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(27646, 28670), var.tunnel1_phase1_lifetime_seconds) ||
    contains(range(28670, 28801), var.tunnel1_phase1_lifetime_seconds))
  error_message = "Valid value falls within the range of 900 and 28800."
  }
}

# The lifetime for phase 1 of the IKE negotiation for the second VPN tunnel, in seconds.
# Valid value is between 900 and 28800.
variable "tunnel2_phase1_lifetime_seconds"{
  default = 28800
  validation {
    condition     = (
    contains(range(900, 1024), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(1024, 2048), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(2048, 3072), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(3072, 4096), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(4096, 5120), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(5120, 6144), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(6144, 7168), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(7168, 8192), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(8192, 9216), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(9216, 10240), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(10240, 11264), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(11264, 12288), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(12288, 13312), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(13312, 14336), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(14336, 15360), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(15360, 16384), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(16384, 17408), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(17408, 18432), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(18432, 19456), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(19456, 20480), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(20480, 21504), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(21504, 22526), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(22526, 23550), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(23550, 24574), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(24574, 25598), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(25598, 26622), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(26622, 27646), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(27646, 28670), var.tunnel2_phase1_lifetime_seconds) ||
    contains(range(28670, 28801), var.tunnel2_phase1_lifetime_seconds)

    )
    error_message = "Valid value falls within the range of 900 and 28800."
  }
}

# List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 2 IKE negotiations.
# Valid values are 2 | 5 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24.
variable "tunnel1_phase2_dh_group_numbers"{
  default = [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
  validation {
    condition     = alltrue([for o in var.tunnel1_phase2_dh_group_numbers : contains([2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], o)])
    error_message = "Valid value is equal to 2 or 14 or 15 or 16 or 17 or 18 or 19 or 20 or 21 or 22 or 23 or 24."
  }
}

# List of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 2 IKE negotiations.
# Valid values are 2 | 5 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24.

variable "tunnel2_phase2_dh_group_numbers"{
  default = [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
  validation {
    condition     = alltrue([for o in var.tunnel2_phase2_dh_group_numbers : contains([2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], o)])
    error_message = "Valid value is equal to 2 or 14 or 15 or 16 or 17 or 18 or 19 or 20 or 21 or 22 or 23 or 24."
  }
}

# List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations.
# Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16.
variable "tunnel1_phase2_encryption_algorithms"{
  default = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
  validation {
    condition     = alltrue([for o in var.tunnel1_phase2_encryption_algorithms : contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], o)])
    error_message = "Valid value is equal to AES128 or AES256 or AES128-GCM-16 or AES256-GCM-16."
  }
}

# List of one or more encryption algorithms that are permitted for the second VPN tunnel for phase 2 IKE negotiations
# Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16.
variable "tunnel2_phase2_encryption_algorithms"{
  default = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
  validation {
    condition     = alltrue([for o in var.tunnel2_phase2_encryption_algorithms : contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], o)])
    error_message = "Valid value is equal to AES128 or AES256 or AES128-GCM-16 or AES256-GCM-16."
  }
}


# List of one or more integrity algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations.
# Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512.
variable "tunnel1_phase2_integrity_algorithms"{
  default = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
  validation {
    condition     = alltrue([for o in var.tunnel1_phase2_integrity_algorithms : contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], o)])
    # contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], var.tunnel1_phase2_integrity_algorithms)
    error_message = "Valid value is equal to SHA1 or SHA2-256 or SHA2-384 or SHA2-512."
  }
}


# List of one or more integrity algorithms that are permitted for the second VPN tunnel for phase 2 IKE negotiations.
# Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512.
variable "tunnel2_phase2_integrity_algorithms"{
  default = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
  validation {
    condition     = alltrue([for o in var.tunnel2_phase2_integrity_algorithms : contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], o)])
    error_message = "Valid value is equal to SHA1 or SHA2-256 or SHA2-384 or SHA2-512."
  }
}

# The lifetime for phase 2 of the IKE negotiation for the first VPN tunnel, in seconds.
# Valid value is between 900 and 3600.
variable "tunnel1_phase2_lifetime_seconds"{
  default = 3600
  validation {
    condition     = (contains(range(900, 1024), var.tunnel1_phase2_lifetime_seconds) || contains(range(1024, 2048), var.tunnel1_phase2_lifetime_seconds) || contains(range(2048, 3072), var.tunnel1_phase2_lifetime_seconds) || contains(range(3072, 3601), var.tunnel1_phase2_lifetime_seconds))
    error_message = "Valid value falls within the range of 900 and 3600."
  }
}

# The lifetime for phase 2 of the IKE negotiation for the second VPN tunnel, in seconds.
# Valid value is between 900 and 3600.
variable "tunnel2_phase2_lifetime_seconds"{
  default = 3600
  validation {
    condition     = (contains(range(900, 1024), var.tunnel2_phase2_lifetime_seconds) || contains(range(1024, 2048), var.tunnel2_phase2_lifetime_seconds) || contains(range(2048, 3072), var.tunnel2_phase2_lifetime_seconds) || contains(range(3072, 3601), var.tunnel2_phase2_lifetime_seconds))
    error_message = "Valid value falls within the range of 900 and 3600."
  }
}


# The percentage of the rekey window for the first VPN tunnel (determined by tunnel1_rekey_margin_time_seconds)
# during which the rekey time is randomly selected. Valid value is between 0 and 100.
variable "tunnel1_rekey_fuzz_percentage"{
  default = 100
  validation {
    condition     = contains(range(0, 101), var.tunnel1_rekey_fuzz_percentage)
    error_message = "Valid value falls within the range of 0 and 100."
  }
}

# The percentage of the rekey window for the second VPN tunnel (determined by tunnel2_rekey_margin_time_seconds)
# during which the rekey time is randomly selected. Valid value is between 0 and 100.
variable "tunnel2_rekey_fuzz_percentage"{
  default = 100
  validation {
    condition     = contains(range(0, 101), var.tunnel2_rekey_fuzz_percentage)
    error_message = "Valid value falls within the range of 0 and 100."
  }
}
# The margin time, in seconds, before the phase 2 lifetime expires, during which the AWS side of the first VPN connection performs an IKE rekey.
# The exact time of the rekey is randomly selected based on the value for tunnel1_rekey_fuzz_percentage. Valid value is between 60 and half of tunnel1_phase2_lifetime_seconds.
variable "tunnel1_rekey_margin_time_seconds"{
  default = 540
  validation {
    condition     = (contains(range(60, 1024), var.tunnel1_rekey_margin_time_seconds) || contains(range(1024, 1801), var.tunnel1_rekey_margin_time_seconds))
    error_message = "Valid value is between 60 and half of tunnel1_phase2_lifetime_seconds."
  }
}

# The margin time, in seconds, before the phase 2 lifetime expires, during which the AWS side of the second VPN connection performs an IKE rekey.
# The exact time of the rekey is randomly selected based on the value for tunnel2_rekey_fuzz_percentage. Valid value is between 60 and half of tunnel2_phase2_lifetime_seconds.
variable "tunnel2_rekey_margin_time_seconds"{
  default = 540
  validation {
    condition     = (contains(range(60, 1024), var.tunnel2_rekey_margin_time_seconds) || contains(range(1024, 1801), var.tunnel2_rekey_margin_time_seconds))
    error_message = "Valid value is between 60 and half of tunnel1_phase2_lifetime_seconds."
  }
}

# The number of packets in an IKE replay window for the first VPN tunnel. Valid value is between 64 and 2048.
variable "tunnel1_replay_window_size"{
  default = 1024
  validation {
    condition     = (contains(range(64, 1024), var.tunnel1_replay_window_size) || contains(range(1024, 2048), var.tunnel1_replay_window_size) || contains(range(2048, 2049), var.tunnel1_replay_window_size))
    error_message = "Valid value is between 64 and 2048."
  }
}

# The number of packets in an IKE replay window for the second VPN tunnel. Valid value is between 64 and 2048.
variable "tunnel2_replay_window_size"{
  default = 1024
  validation {
    condition     = (contains(range(64, 1024), var.tunnel2_replay_window_size) || contains(range(1024, 2048), var.tunnel2_replay_window_size) || contains(range(2048, 2049), var.tunnel2_replay_window_size))
    error_message = "Valid value is between 64 and 2048."
  }
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
# TAGS | -------> Exposes a uniform system of tagging.
#-----------------------------------------------------------------------------------------------------
# Variables that makes up the AWS Tags assigned to the VPC on creation.
# ----------------------------------------------------------------------------------------------------
variable "Application_ID" {
  description = "The Application ID for this application built by AWS."
  type = string
  default = "transit-gateway-builder-v0"
}

variable "Application_Name" {
  description = "The name of this application."
  type = string
  default = "aws-fsf-transit-gateway-builder"
}

variable "Business_Unit" {
  description = "Your business unit or line of business name"
  type = string
  default = "YourBusinessUnitName"
}

variable "Environment_Type" {
  description = "The environment type defaults to PRODUCTION and cannot be changed"
  type = string
  default = "PRODUCTION"
  validation {
    condition     = (var.Environment_Type == "PRODUCTION")
    error_message = "External Principals should not be allowed unless in the case of a merger."
  }
}

variable "Supported_Networks" {
  description = "Administrative use only and should not be changed"
  type = string
  default = "Spoke_VPCs_Under_This_Organization"
  validation {
    condition     = (var.Supported_Networks == "Spoke_VPCs_Under_This_Organization")
    error_message = "Spoke_VPCs_Under_This_Organization is the only supported value."
  }
}

variable "CostCenterCode" {
  description = "Your cost center code for billing purposes"
  type = string
  default = "YourCostCenterCode"
}

variable "CreatedBy" {
  description = "CSI Billing Profile Number associated with application to be hosted in this vpc."
  type = string
  default = "YourName"
}

variable "Manager" {
  description = "CSI Billing Profile Number associated with application to be hosted in this vpc."
  type = string
  default = "YourManagerName"
}

