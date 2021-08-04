#-----------------------------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | ---> Creates AWS Transit Gateway route tables that are needed by the network deployer solution
#-----------------------------------------------------------------------------------------------------------------------
enable_integration_with_network_deployer_solution = {
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
# -----------------------------------------------------------------------------------------------------
#
# -----------------------------------------------------------------------------------------------------
default_route_table_propagation = {
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

# -----------------------------------------------------------------------------------------------------
#
# -----------------------------------------------------------------------------------------------------
default_route_table_association = {
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

# -----------------------------------------------------------------------------------------------------
#
# -----------------------------------------------------------------------------------------------------
vpn_ecmp_support = {
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

# -----------------------------------------------------------------------------------------------------
#
# -----------------------------------------------------------------------------------------------------
dns_support = {
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


#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | ---> Create Network Manager
#-----------------------------------------------------------------------------------------------------
# This variables tells the solution if an AWS Network Manager exist (true) or not (false).
#-----------------------------------------------------------------------------------------------------
network_manager_deployment  = false

#-----------------------------------------------------------------------------------------------------
# This variables holds the name an AWS Network Manager
#-----------------------------------------------------------------------------------------------------
network_manager_name = "transit-gateway-network-manager-stack"


# ----------------------------------------------------------------------------------------------------
# Please update this variable if you have an AWS Network Manager deployed.
# The full AWS ARN is required for your AWS Network Manager.
# ----------------------------------------------------------------------------------------------------
network_manager_id = "global-network-05240d427b8bc23a0" # "your-global-network-id-here"



#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | ---> Manages VPN Attachment Association.
#  True results in only the packet inspection table being populated with routes.
#  False results in the addition of on-premises routes added to the dev, uat, prod, shared services, and packet inspection transit gateway route table.
#-----------------------------------------------------------------------------------------------------
centralized_packet_inspection_enabled = {
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

#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | ---> AWS Site-to-Site
#-----------------------------------------------------------------------------------------------------
# This variables map tells the solution if it should create an AWS Site-to-Site VPN and which region
# Simply set true for the region in which you would like to deploy
#-----------------------------------------------------------------------------------------------------
create_site_to_site_vpn = {
    ohio          = true
    n_virginia    = true
    oregon        = true
    n_california  = true
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

#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | --->  Create Transit Gateway
#-----------------------------------------------------------------------------------------------------
# This variable controls the creation of a transit gateway in the region to the left.
# Simply set true if you want to create or false if you dont want to create.
# The option "all_aws_region" allows you to create a transit gateway in all AWS Region.
# There's no need to specify true for individual regions if "all_aws_region" is set to true.
#-----------------------------------------------------------------------------------------------------
deploy_transit_gateway_in_this_aws_region = {
    all_aws_regions                       = true  # false
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

#-----------------------------------------------------------------------------------------------------
#  AWS Transit Gateway | --->  Create Transit Gateway Peering Connection
#-----------------------------------------------------------------------------------------------------
# This variable controls the creation of a transit gateway peering between transit gateways deployed in different AWS Regions.
# The option "build_complete_mesh" complements the "all_aws_region" in the variable "deploy_transit_gateway_in_this_aws_region"
# Set "build_complete_mesh" to true if you have set "all_aws_region" to true AND you would like to build a completely globally meshed transit gateway network.
#-----------------------------------------------------------------------------------------------------
transit_gateway_peering = {
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


#-----------------------------------------------------------------------------------------------------
# AWS Transit Gateway | ---> Transit Gateway Configuration Parameter
#-----------------------------------------------------------------------------------------------------
ram_share_name = "shared_networking_resources"


# -----------------------------------------------------------------------------------------------------
#
# -----------------------------------------------------------------------------------------------------
remote_site_asn = {
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

# -----------------------------------------------------------------------------------------------------
#
# -----------------------------------------------------------------------------------------------------
remote_site_public_ip ={
    hq                                    = "127.0.0.1"
    ohio                                  = "50.0.0.1"
    n_virginia                            = "51.0.0.1"
    oregon                                = "52.0.0.1"
    n_california                          = "53.0.0.1"
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

# -----------------------------------------------------------------------------------------------------
#
# -----------------------------------------------------------------------------------------------------
how_many_vpn_connections = {
    hq                                    = 0
    ohio                                  = 10
    n_virginia                            = 10
    oregon                                = 10
    n_california                          = 10
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



# -----------------------------------------------------------------------------------------------------
# Advance VPN Configuration
# -----------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------
# Indicate whether to enable acceleration for the VPN connection. Supports only EC2 Transit Gateway.
# -----------------------------------------------------------------------------------------------------
enable_acceleration = {
    ohio          = true
    n_virginia    = true
    oregon        = true
    n_california  = true
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

# -----------------------------------------------------------------------------------------------------
# Indicate whether the VPN tunnels process IPv4 or IPv6 traffic. Valid values are ipv4 | ipv6.
# ipv6 Supports only EC2 Transit Gateway.
# -----------------------------------------------------------------------------------------------------
tunnel_inside_ip_version = "ipv4"


# -----------------------------------------------------------------------------------------------------
#
# -----------------------------------------------------------------------------------------------------
tunnel_inside_cidrs = {
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


# -----------------------------------------------------------------------------------------------------
# The preshared key of the first VPN tunnel.
# The preshared key must be between 8 and 64 characters in length and cannot start with zero(0).
# Allowed characters are alphanumeric characters, periods(.) and underscores(_).
# -----------------------------------------------------------------------------------------------------
tunnel1_preshared_key = {
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


# -----------------------------------------------------------------------------------------------------
# The preshared key of the second VPN tunnel.
# The preshared key must be between 8 and 64 characters in length and cannot start with zero(0).
# Allowed characters are alphanumeric characters, periods(.) and underscores(_).
# -----------------------------------------------------------------------------------------------------
tunnel2_preshared_key = {
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

# -----------------------------------------------------------------------------------------------------
# The action to take after DPD timeout occurs for the first VPN tunnel.
# Specify restart to restart the IKE initiation.
# Specify clear to end the IKE session. Valid values are clear | none | restart.
# -----------------------------------------------------------------------------------------------------
tunnel1_dpd_timeout_action =  "clear"


# -----------------------------------------------------------------------------------------------------
# The action to take after DPD timeout occurs for the first VPN tunnel.
# Specify restart to restart the IKE initiation. Specify clear to end the IKE session.
# Valid values are clear | none | restart.
# -----------------------------------------------------------------------------------------------------
tunnel2_dpd_timeout_action= "clear"


# -----------------------------------------------------------------------------------------------------
# The number of seconds after which a DPD timeout occurs for the first VPN tunnel.
# Valid value is equal or higher than 30.
# -----------------------------------------------------------------------------------------------------
tunnel1_dpd_timeout_seconds = 30


# The number of seconds after which a DPD timeout occurs for the second VPN tunnel.
# Valid value is equal or higher than 30.
# -----------------------------------------------------------------------------------------------------
tunnel2_dpd_timeout_seconds = 30


# The IKE versions that are permitted for the first VPN tunnel. Valid values are ikev1 | ikev2.
# -----------------------------------------------------------------------------------------------------
tunnel1_ike_versions = ["ikev1","ikev2"]


# The IKE versions that are permitted for the second VPN tunnel. Valid values are ikev1 | ikev2.
tunnel2_ike_versions = ["ikev1","ikev2"]



# List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 1 IKE negotiations.
# Valid values are 2 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24.
# -----------------------------------------------------------------------------------------------------
tunnel1_phase1_dh_group_numbers =  [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]



# List of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 1 IKE negotiations.
# Valid values are 2 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24.
# -----------------------------------------------------------------------------------------------------
tunnel2_phase1_dh_group_numbers =  [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]



# List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations.
# Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16.
# -----------------------------------------------------------------------------------------------------
tunnel1_phase1_encryption_algorithms= ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]



# List of one or more encryption algorithms that are permitted for the second VPN tunnel for phase 1 IKE negotiations.
# Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16.
# -----------------------------------------------------------------------------------------------------
tunnel2_phase1_encryption_algorithms = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]


# One or more integrity algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations.
# Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512.
# -----------------------------------------------------------------------------------------------------
tunnel1_phase1_integrity_algorithms = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]


# One or more integrity algorithms that are permitted for the second VPN tunnel for phase 1 IKE negotiations.
# Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512.
# -----------------------------------------------------------------------------------------------------
tunnel2_phase1_integrity_algorithms= ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]



# The lifetime for phase 1 of the IKE negotiation for the first VPN tunnel, in seconds.
# Valid value is between 900 and 28800.
# -----------------------------------------------------------------------------------------------------
tunnel1_phase1_lifetime_seconds = 28800


# The lifetime for phase 1 of the IKE negotiation for the second VPN tunnel, in seconds.
# Valid value is between 900 and 28800.
# -----------------------------------------------------------------------------------------------------
tunnel2_phase1_lifetime_seconds = 28800



# List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 2 IKE negotiations.
# Valid values are 2 | 5 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24.
# -----------------------------------------------------------------------------------------------------
tunnel1_phase2_dh_group_numbers= [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]


# List of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 2 IKE negotiations.
# Valid values are 2 | 5 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24.
# -----------------------------------------------------------------------------------------------------
tunnel2_phase2_dh_group_numbers = [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]


# List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations.
# Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16.
# -----------------------------------------------------------------------------------------------------
tunnel1_phase2_encryption_algorithms = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]


# List of one or more encryption algorithms that are permitted for the second VPN tunnel for phase 2 IKE negotiations
# Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16.
# -----------------------------------------------------------------------------------------------------
tunnel2_phase2_encryption_algorithms = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]


# List of one or more integrity algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations.
# Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512.
# -----------------------------------------------------------------------------------------------------
tunnel1_phase2_integrity_algorithms = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]


# List of one or more integrity algorithms that are permitted for the second VPN tunnel for phase 2 IKE negotiations.
# Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512.
# -----------------------------------------------------------------------------------------------------
tunnel2_phase2_integrity_algorithms = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]


# The lifetime for phase 2 of the IKE negotiation for the first VPN tunnel, in seconds.
# Valid value is between 900 and 3600.
# -----------------------------------------------------------------------------------------------------
tunnel1_phase2_lifetime_seconds = 3600


# The lifetime for phase 2 of the IKE negotiation for the second VPN tunnel, in seconds.
# Valid value is between 900 and 3600.
# -----------------------------------------------------------------------------------------------------
tunnel2_phase2_lifetime_seconds = 3600



# The percentage of the rekey window for the first VPN tunnel (determined by tunnel1_rekey_margin_time_seconds)
# during which the rekey time is randomly selected. Valid value is between 0 and 100.
# -----------------------------------------------------------------------------------------------------
tunnel1_rekey_fuzz_percentage = 100


# The percentage of the rekey window for the second VPN tunnel (determined by tunnel2_rekey_margin_time_seconds)
# during which the rekey time is randomly selected. Valid value is between 0 and 100.
# -----------------------------------------------------------------------------------------------------
tunnel2_rekey_fuzz_percentage = 100


# The margin time, in seconds, before the phase 2 lifetime expires, during which the AWS side of the first VPN connection performs an IKE rekey.
# The exact time of the rekey is randomly selected based on the value for tunnel1_rekey_fuzz_percentage. Valid value is between 60 and half of tunnel1_phase2_lifetime_seconds.
# -----------------------------------------------------------------------------------------------------
tunnel1_rekey_margin_time_seconds = 540


# The margin time, in seconds, before the phase 2 lifetime expires, during which the AWS side of the second VPN connection performs an IKE rekey.
# The exact time of the rekey is randomly selected based on the value for tunnel2_rekey_fuzz_percentage. Valid value is between 60 and half of tunnel2_phase2_lifetime_seconds.
# -----------------------------------------------------------------------------------------------------
tunnel2_rekey_margin_time_seconds = 540


# The number of packets in an IKE replay window for the first VPN tunnel. Valid value is between 64 and 2048.
# -----------------------------------------------------------------------------------------------------
tunnel1_replay_window_size = 1024


# The number of packets in an IKE replay window for the second VPN tunnel. Valid value is between 64 and 2048.
tunnel2_replay_window_size = 1024



# The action to take when the establishing the tunnel for the first VPN connection.
# By default, your customer gateway device must initiate the IKE negotiation and bring up the tunnel.
# Specify start for AWS to initiate the IKE negotiation. Valid values are add | start.
# -----------------------------------------------------------------------------------------------------
tunnel1_startup_action = "add"


# The action to take when the establishing the tunnel for the second VPN connection.
# By default, your customer gateway device must initiate the IKE negotiation and bring up the tunnel.
# Specify start for AWS to initiate the IKE negotiation. Valid values are add | start.
# -----------------------------------------------------------------------------------------------------
tunnel2_startup_action = "add"


#-----------------------------------------------------------------------------------------------------
# TAGS | -------> Exposes a uniform system of tagging.
#-----------------------------------------------------------------------------------------------------
# Variables that makes up the AWS Tags assigned to the VPC on creation.
# ----------------------------------------------------------------------------------------------------
Application_ID      = "transit-gateway-builder-v0"          # do not change this value
Application_Name    = "aws-fsf-transit-gateway-builder"     # do not change this value
Business_Unit       = "YourBusinessUnitName"
Environment_Type    = "PRODUCTION"                          # do not change this value
Supported_Networks  = "Spoke_VPCs_Under_This_Organization"  # do not change this value
CostCenterCode      = "YourCostCenterCode"
CreatedBy           = "YourName"
Manager             = "YourManagerName"


