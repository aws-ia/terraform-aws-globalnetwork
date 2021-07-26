# An Opinionated Transitive Solution for AWS Customers
```hcl-terraform 

Solution Created By:      Androski Spicer

Documentation Written By: Androski Spicer

Last Updated: July 2021

```

# Table of Contents

1. [About This Document](#about-this-document)

2. [Overview](#overview)

3. [Assumptions](#assumptions)

4. [The Transitive Network](#the-transitive-network)

5. [The AWS Transit Gateway Repository and modules](#the-aws-transit-gateway-repository-and-modules)

6. [Implementation Guide ](#implementation-guide)

7. [Conclusion](#conclusion)

# About This Document

This document serves to introduce and discuss an opinionated transitive solution that enables customers to deploy multiple configurations of AWS Transit Gateways. 
These configurations range from the implementation of a single transit gateway to a globally meshed network of transit gateways that are managed by AWS Network Manager. 


# Overview

This solution provides customers with a set of opinionated Terraform modules that deploys and automates the
configuration of one or more AWS Transit Gateway(s). 

Today, this solution supports three key architecture types;

-   **A Single Transit GatewayLayer Three/Transitive Network(s)**

    -   This option deploys a single transit gateway and shares it throughout the customer AWS Organization

-   **Multiple Transit Gateways Deployed Across Multiple AWS Regions**

    -   This option creates an AWS Transit Gateway in multiple AWS Regions
    -   Customers can enable a transit gateway peer between both AWS Transit Gateways

-   **Globally Meshed Network of AWS Transit Gateways**

    -   This deployment option deploys an AWS Transit Gateway in each AWS Region and establishes a
        transit gateway peering connection between all transit gateways deployed by this solution. 

Within the variables.tf file is a set of boolean maps that customers can tune to deploy any of the above configuration type.
These controls make it easy for a customer to go from no transit gateway to a globally meshed network of AWS Transit Gateways with IPSec VPN termination and automatic VPN attachment route propagation. 

The solution presented is highly opinionated. Within this opinion is room for a customer to achieve the desired configuration as along as the feature is available within this solution.
That said, with this solution comes with a set of custom items. They are as followed:

Each AWS Transit Gateway deployed by this solution comes with the following

- **Six AWS Transit Gateway Route Tables (These are not optional)**
    - Development (DEV) Route Table 
    - User Acceptance Testing (UAT) Route Table 
    - Production (PROD) Route Table 
    - Shared Services Route Table 
    - Packet Inspection Route Table 
    - On-premises Route Table 

- **ECMP is enabled by default and is not optional**
- **Route Propagation & Route Table Association with the Default Transit Gateway Route Table is disabled by default**
    - All propagation and assocation is controlled by
        - Boolean maps outlined in this document and present within the Terraform modules 
        - AWS Tag data
- **AWS Site-to-Site VPN(s)**
    - This is an optional feature; customers can enable or disable this feature
    - Once enbaled, a customer can choose to create N number of AWS Site to Site VPNs to the same customer gateway
      then use ECMP to load balance across them. 
    - By default, the VPN Attachment(s) routes are automatically propagated to the shared services, dev, prod and uat transit gateway route table if packet inspection is not enabled
    - If packet inspection is enabled on this solution, then the on-premises routes are automatically propagated
      to the packet inspection route table.
    
This solution contains an AWS CloudFormation (CFN) Stack for launching an AWS Network Manager. 
The CFN stack can be found in the folder labeled "network-manager-cloudformation-template".
Today, Terraform does not expose a resource for the creation an AWS Network Manager. They are, however, working on creating a resource. 
This solution will be modified to include this terraform resource once it is available.  

In the mean, if you chose to enable network manager integration, you will have to supply the network manager id and populate it to the variable "network_manager_id" which can be found in the ./variables.tf file. 
You can provide an ID from a network manager that you already have or launch a new network manager using the CFN stack available in this solution then supply the network manager ID.

# Assumptions

The solutions outlined in this document is primarily written in
[Hashicorp
Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).
The AWS Lambda functions are built by and used in this solution is
written in Python.

This document, therefore, assumes that you are familiar with Terraform
and Terraform terminology. If you plan to modify the AWS Lambda
function's Python code then please be adept in Python.

Also, this is a document that refers to AWS networking components. It is
assumed that you are familiar with AWS Virtual Private Cloud (VPC), AWS
Transit Gateway, AWS Route 53 Hosted Zones and Route 53 Resolvers.

Other AWS services are mentioned as well. These are AWS EventBridge,
EventBus, and AWS Organizations.

The below links provides insight into these AWS services.

1.  **AWS VPC**

    -   <https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html>

2.  **AWS Transit Gateway**

    -   <https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html>

3.  **AWS Route 53**

    -   <https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/getting-started.html>

4.  **AWS Route 53 Resolver**

    -   <https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver.html>

5.  **AWS Organizations**

    -   <https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html>

6.  **AWS EventBridge**

    -   <https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html>


# The Transitive Network 

The transitive network built by this solution leverages the AWS Transit
Gateway as the layer three hub for each AWS Region.

The terraform modules that builds this solution exposes multiple object
maps that customers can tune to build their transitive network the way
they want it.

For example, a customer can launch a transit gateway configuration that
ranges from a single gateway in one region to multiple transit gateways
across multiple AWS Regions.

That said, transit gateways can be deployed as stand-alone gateways or
gateways that are connected via AWS Transit Gateway peering. Customers
have options when specifying transit gateway peering relationship. These
options ranges from peering two or more gateways across different AWS
Regions to creating a completely meshed network of transit gateways
globally.

Within the transitive network is an AWS Network Manager. This Network
Manager is created once and it is created before any transit gateway.

Each transit gateway is automatically associated with the Network
Manager.

This solution also allows customers to create **N** number of AWS site
to site VPNs. ECMP is enabled on each transit gateway by default and
default route tables propagation is disabled. Six transit gateway route
tables are created; Shared Services, Packet Inspection, Dev, Prod, UAT
and on-premises. Spoke VPCs are associated with the right route table
based on their environment tag.

Route tables are automatically configured based on the specified traffic
patterns.

Illustration of a Boolean map that allows customers to specify where
their transit gateways are deployed

```hcl-terraform
variable "deploy_transit_gateway_in_this_aws_region" {
    type = map(bool)
    default = {
        all_aws_regions = true # false
        ohio = false # true
        n_virginia = false      # true
        oregon = false          # true
        n_california = false    # true
        canada_east = false     # true
        ireland = false         # true
        london = false          # true
        stockholm = false       # true
        frankfurt = false       # true
        paris = false           # true
        tokyo = false           # true
        seoul = false           # true
        sydney = false          # true  
        mumbai = false          # true
        singapore = false       # true
        sao-paulo = false       # true
    }
}
```
Illustration of a Boolean map that allows customers to specify how their
transit gateways are peered

```hcl-terraform
variable "transit_gateway_peering" {
    type = map(bool)
    default = {
        build_complete_mesh = true     # false
        ohio_n_virginia = false        # true
        ohio_canada_east = false       # true
        ohio_oregon = false            # true
        ohio_n_california = false      # true
        oregon_n_california = false    # true
        oregon_canada_east = false     # true
        oregon_n_virginia = false      # true
        oregon_n_sao_paulo = false     # true
        oregon_n_london = false                # true
        # n_california_canada_east = false     # true
        n_california_n_virginia = false        # true
        n_virginia_canada_east = false # true
        n_virginia_n_london = false    # true
        n_virginia_sao_paulo = false   # true
        london_n_ireland = false       # true
        london_n_paris = false         # true
        london_n_frankfurt = false     # true
        london_n_milan = false         # true
        london_n_stockholm = false     # true
        ireland_n_paris = false        # true
        ireland_n_frankfurt = false    # true
        ireland_n_stockholm = false    # true
        frankfurt_n_stockholm = false  # true
        frankfurt_n_paris = false      # true
        stockholm_n_paris = false      # true
        mumbai_n_frankfurt = false     # true
        mumbai_n_sao_paulo = false     # true
        mumbai_n_tokyo = false         # true
        mumbai_n_seoul = false         # true
        mumbai_n_singapore = false     # true
        mumbai_n_sydney = false        # true
        singapore_n_sydney = false     # true
        singapore_n_tokyo = false      # true
        singapore_n_sao_paulo = false  # true
        singapore_n_seoul = false      # true
        sydney_n_seoul = false         # true
        sydney_n_tokyo = false         # true
        sydney_n_sao_paulo = false     # true
        tokyo_n_seoul = false          # true
        tokyo_n_sao_paulo = false      # true
        paris_n_sao_paulo = false      # true
    }
}
```
Illustration of a global transit gateways network all connected using
transit gateway peering


AWS Transit Gateway route tables gives AWS customers full control over
how their packets should be routed.

One such functionality is routing domain isolation similar to that of
virtual routing and forwarding (VRFs) found in traditional networks.

Out of the box, this solution isolates are routing domains and
selectively leaks routes based on the specified traffic pattern.

There are two explicit traffic patterns; packet inspection for east-west
traffic where Inspection is performed inside the AWS eco system. The
other pattern is east-west traffic with no packet inspection.

For east-west packet inspection, spoke VPCs that exist inside one of the
three environment types (dev, UAT, prod) will only have a default route
that points to the packet inspection VPC. On-premises routes can also be
propagated to these route tables.

If packet inspection is not enabled then the solution automatically
configures a specific route to the shared services VPC(s).

Spoke VPC Transit Gateway attachments and routes configuration are
automatically configured when a Spoke VPC is created. Routes are added
to the VPC route tables and the transit gateway route tables.

All configuration discussed so far are automatic up on a terraform apply
command being issued.

The repository for the transitive network is different from the
repository for the other network types.


## **The AWS Transit Gateway Repository and modules**

The transit gateway solution is made up of three sub modules and several
files that are found in the root of the directory. A visual structure of
the solution can be seen below:

**Structure**
```hcl-terraform
.
├──_create_transit_gateway
├── main.tf
├── variables.tf
│ └── outputs.tf
├──_peer_transit_gateway
├── main.tf
├── variables.tf
│ └── outputs.tf
├── _transit-gateway-network-manager
├── main.tf
├── variables.tf
│ └── outputs.tf
│
├── main.tf
│
├── variables.tf
│
├── outputs.tf
│
├── versions.tf
│
├── backend.tf
│
├── provider.tf
│
├── outputs.tf
│
├── lambda_function.py

```

All components of this solution works together to give customers the
ability to create their layer three network according to their needs.
For some customers this can be a single AWS Transit Gateway in a single
AWS Region or two AWS Transit Gateways in different AWS Regions that are
peered. For other customers it might be a globally meshed network of AWS
Transit Gateways that are managed by AWS Network Manager.

Customers are able to tune the solution to build what they need by
configuring the variable object maps that are found inside the
*variables.tf* file in each directory/sub-module. Let's take a look at
each sub-module and discuss what they do.

###Note:

-------

All the configurable pieces of each of the sub-modules in this solution
are controlled by the variables.tf file in the root of the solutions
directory.

Therefore, if you want to pass a configurable variable then you need to
add it to the variables declared inside the root variables.tf file.

There are variables that are not configurable. These variables are
protected by a validation condition that enforces a specific
configuration.
-------
####
***\_create_transit_gateway***

This sub-module is responsible for creating the following:

-   **An AWS Transit Gateway**

    -   This transit gateway is configured to enable ECMP support and
        auto accept shared attachment for attachments that are in the
        same AWS Organizations as the transit gateway.

    -   For control and isolation purposes, default route table
        association and route propagation is disabled. DNS Support is
        also disabled.

    -   DNS Support and the Amazon Side ASN configurable. This solution
        automatically assign a unique ASN to each AWS Transit gateway.
        This future proofs the solution for automatic propagation of
        routes from one peered transit gateway to another. This feature
        is not available today but it will be available in the future.

        -   To configure DNS Support please use configure the following
            variable inside the variables.tf file in this sub-module

            -   variable \"dns_support\" {\
                default = \"disable\"\
                }

    -   The creation of this transit gateway is managed by the following
        variable. Changing the Boolean value determines whether the
        transit gateway is created or not.

        -   variable \"transit_gateway_deployment\" {\
            default = true\
            validation {\
            condition = (var.transit_gateway_deployment == false \|\|
            var.transit_gateway_deployment == true)\
            error_message = \"Transit Gateway deployment must be either
            true or false.\"\
            }\
            }

        -   It is import to note that the default value can only be true
            or false. Any other value will cause an error to be thrown
            by Terraform.

        -   All other variables are not configurable.

-   **AWS Resource Access Manager Resource Share**

    -   The transit gateway created above is shared through out the
        customers AWS Organization via this resource share. The resource
        share is configured to not allow access from entities outside
        the AWS Organization. This is handled by the following variable.
        It is not configurable.

        -   variable \"allow_external_principals\" {\
            default = false\
            validation {\
            condition = (var.allow_external_principals == false)\
            error_message = \"External Principals should not be allowed
            unless in the case of a merger.\"\
            }\
            }

-   **AWS Transit Gateway Route Tables**

    -   Seven AWS Transit Gateway route tables are created by this
        solution. They are:

        -   Default Route Table

            -   Nothing is automatically associated with this route
                table

        -   Dev/Development Route Table

            -   VPCs tagged with ***development*** are automatically
                associated with this route table

        -   UAT/User Acceptance Testing Route Table

            -   VPCs tagged with ***uat*** are automatically associated
                with this route table

        -   Prod/Production Route Table

            -   VPCs tagged with ***prod*** are automatically associated
                with this route table

        -   Packet Inspection Route Table

            -   VPCs tagged with ***packet inspection*** are
                automatically associated with this route table

        -   North South Route Table

            -   AWS Site-2-Site VPN(s) are automatically associated with
                this route table

        -   Shared Services

            -   VPCs tagged with ***shared-services*** are automatically
                associated with this route table

    -   The creation of these route tables are controlled by the route
        tables variable Boolean map. Customers can chose to create a
        route table by adding true for that route table in the Boolean
        map. An example of the map is shown below

        -   variable \"route_tables\" {\
            type = map(bool)\
            default = {\
            shared_services_route_table = true\
            north_south_route_table = true\
            packet_inspection_route_table = true\
            development_route_table = true\
            production_route_table = true\
            uat_route_table = true\
            }\
            }

-   **AWS Site-2-Site VPN (BGP Routing Protocol)**

    -   This sub-module also provides customers with the option to
        create AWS Site-2-Site VPN(s) that are associated with the AWS
        Transit Gateway.

    -   Customers can choose to create one AWS Site-2-Site VPN or
        multiple. The number of these VPNs that are created is
        determined by the two variables;
```hcl-terraform
variable "create_site_to_site_vpn" {
    default = true
    validation {
        condition = (var.create_site_to_site_vpn == false ||
        var.create_site_to_site_vpn == true)
        error_message = "Create site to site VPN must be either true or false."
    }
}

variable "how_many_vpn_connections" {
   default = 1
}
```
-   The variable "create_site_to_site_vpn" determines instructs
    Terraform to create this resource or not.

-   The variable "how_many_vpn_connections" simply tells Terraform how
    many VPN connections to create. These connections are to the same
    customer gateway which results in the aggregation of these
    connections. This is possible because of the enablement of ECMP on
    the Transit Gateway.

####***_peer_transit_gateway***

The *peer_transit_gateway* sub-module is responsible for establishing an
AWS Transit Gateway peering connection between two transit gateways that
are in different AWS Regions. Please note that as of this writing,
transit gateways can only be peered if they reside in different AWS
Regions.

The creation of an inter-region peering relationship can only be
establish if the following variables are set to true. By default, they
are set to *true.*
```hcl-terraform
variable "transit_gateway_deployment" {
    default = true
    validation {
        condition = (var.transit_gateway_deployment == false ||
        var.transit_gateway_deployment == true)
        error_message = "Transit Gateway deployment must be either true or false."
    }
}


variable "transit_gateway_peering_enabled" {
    default = true
    validation {
        condition = (var.transit_gateway_peering_enabled == false || var.transit_gateway_peering_enabled == true)
        error_message = "Transit Gateway Peering enabled must be either true or false."
    }
}
```
There is room operate in these variables but that room is confined by
the variable type; that is, it is Boolean. This is enforced by
validation condition and terraform data type controls.

This sub-module is tightly dependent on the
***\_create_transit_gateway*** sub-module.

***\_transit-gateway-network-manager***

Lastly, there is the transit-gateway-network-manager sub-module. This
module, as the name suggests, creates an AWS Network Manager. All
transit gateways that are created by this solution are automatically
associated with this network manager. This automatic association of the
transit gateway with the network manager is achieved by the invocation
of an AWS Lambda function. This function is triggered by Terraform after
the creation of each transit gateway.

The first set of resources created by this transit gateway solution are
the AWS Network Manager and the AWS Lambda function that does the
transit gateway association task. All other resource creation is
dependent on the availability of these infrastructure resources.

It is important to note that Terraform doesn't have a resource that
facilitates the creation of an AWS Network Manager. The
*\_transit-gateway-network-manager* leverages the Terraform resource
that allows you to define a CloudFormation stack. Within the defined
stack exists an *Output* definition. This output is imported by the AWS
Lambda function that performs the association of AWS Transit Gateways
with the AWS Network Manager.

***Illustration of embedding CloudFormation in Terraform***
```hcl-terraform
resource "aws_cloudformation_stack" "create_transit_gateway_network_manager_global_network" {
    name = var.network_manager_name
    
    template_body = <<STACK
    {
        "Resources" : {
            "myGlobalNetwork": {
                "Type": "AWS::NetworkManager::GlobalNetwork",
                "Properties": {
                "Description": "Global Network",
                "Tags": [{
                    "Key": "Name",
                    "Value": "aws-fsf-global-network"
                }]
                }
           }
       },
    "Outputs" : {
        "GlobalNetworkId" : {
        "Description" : "Global Network ID",
        "Value" : { "Fn::GetAtt" : [ "myGlobalNetwork", "Id" ]}
    }
   }
 }
STACK
}
```
***\
Orchestration of the transit gateway sub-modules***

All sub-modules mentioned above are not functional on their own. A
*terraform apply* in the sub-modules would result in errors as
configurations like providers, etc. are not present. They are
purposefully built like this.

*Terraform apply* should be made at the root of the solutions directory.
The main.tf file is built in a systematic way so that the creation of
resources are done in the right order. Building the solution this was
abstracts complexity away from the point of interaction for each
customer.

The order in which things are created are as followed:

1.  AWS Network Manager (created once and in one AWS Region)

2.  AWS Lambda Function (created once and in one AWS Region)

3.  Transit Gateway *(created in each AWS Region depending on the
    configuration in the variables file.)*

4.  Transit Gateway Peering Connections *(created in each AWS Region
    depending on the configuration in the variables file.)*

The obfuscation that has been used in the isolation of these modules
removes the need from customers to understand what's inside the
*main.tf* file.

Instead, it is recommended that customers and users grasp the variables
that have been declared in the variables.tf file.

The variables inside the variables.tf file maps to that were mentioned
earlier in the sub-module section.

The variables that are important to configure will be discussed through
out the rest of this section. These variables determines

1.  If a transit gateway is created and which region

2.  If multiple transit gateways are peered

3.  If and how many VPN connections are made

4.  If transit gateways created are associated with the network manager

Looks take a closer look at the variables that controls these
activities.

The most important and only variables that a customer needs to know
about are as follows:

1.  ```hcl-terraform 
    variable "transit_gateway_deployment" {}
    ```

2.  ```hcl-terraform 
    variable "create_site_to_site_vpn" {}
    ```

3.  ```hcl-terraform 
    variable "deploy_transit_gateway_in_this_aws_region" {}
     ```

4.  ```hcl-terraform 
    variable "transit_gateway_peering" {}
     ```

5.  ```hcl-terraform 
    variable "how_many_vpn_connections"{}
     ```

Let's look at each of these individually.

```hcl-terraform  
variable "transit_gateway_deployment" {}
```

This is a variable of type Boolean. It determines if transit gateways
are deployed and should always be *true*.

**Structure**
```hcl-terraform 
variable "transit_gateway_deployment" {
    default = true
    validation {
        condition = (var.transit_gateway_deployment == false || var.transit_gateway_deployment == true)
        error_message = "Transit Gateway deployment must be either true or false."
    }
}
``` 

```hcl-terraform  
variable "create_site_to_site_vpn" {}
```
 
This is a Boolean map that allows a customer to specify which AWS Region
they would like to create an AWS Site-2-Site VPN.

The bool map is constructed in a way that it correlates to all other
important variables and how one specifies that a resource is created or
not.

That is a customer turns on a region for a resource by selecting the
region and specifying true.

This bool map can be seen below:

```hcl-terraform 
variable "create_site_to_site_vpn" {
    type = map(bool)
    default = {
        ohio = true
        n_virginia = false
        oregon = false
        n_california = false
        canada_east = false
        ireland = false
        london = false
        stockholm = false
        frankfurt = false
        paris = false
        tokyo = false
        seoul = false
        sydney = false
        mumbai = false
        singapore = false
        sao_paulo = false
    }
}
``` 
An example of how this variable is used in the *main.tf* is highlighted
below in white and underlined.

```hcl-terraform
module "terraform-aws-fsf-tgw-deployment-ohio" {
    source = "./create_transit_gateway"
    count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions== true) || (var.deploy_transit_gateway_in_this_aws_region.ohio ==true) ? **1**:**0**)
    providers = {
          aws = aws.ohio
    }
    create_site_to_site_vpn = var.create_site_to_site_vpn.ohio
    amazon_side_asn = "64513" # BGP ASNs must be unique for each AWS TGW if you intend to peer & route between them.
    transit_gateway_deployment = false
}
```

```hcl-terraform
variable "deploy_transit_gateway_in_this_aws_region" {}
```

The *deploy_transit_gateway_in_this_aws_region* variable is an object
map of Booleans. This variable allows users to specify the AWS Region in
which they would like to deploy an AWS Transit Gateway.

A customer can enable one region at a time by setting the region to
equal to true. Customers can skip this step and deploy a transit gateway
in all regions by taking advantage of a short cut that's built into the
bool map.

This short cut is the *all_aws_regions* option inside the default
segment of the bool map. It is important that the AWS Regions listed in
the illustration below are enabled in your account. For more details on
enabling an AWS Region please see the following URL.

<https://docs.aws.amazon.com/general/latest/gr/rande-manage.html>

***Illustration of deploy_transit_gateway_in_this_aws_region variable***

```hcl-terraform
variable "deploy_transit_gateway_in_this_aws_region" {
    type = map(bool)
    default = {
        all_aws_regions     = true      # false
        ohio                = false     # true
        n_virginia          = false     # true
        oregon              = false     # true
        n_california        = false     # true
        canada_east         = false     # true
        ireland             = false     # true
        london              = false     # true
        stockholm           = false     # true
        frankfurt           = false     # true
        paris               = false     # true
        tokyo               = false     # true
        seoul               = false     # true
        sydney              = false     # true
        mumbai              = false     # true
        singapore           = false     # true
        sao-paulo           = false     # true

    }
}
```
```hcl-terraform 
variable "transit_gateway_peering" {}
```

The transit_gateway_peering variable is also a map of Booleans. This map
contains a naming convention of two AWS Regions. For example
*ohio_n\_virginia = true.* This means that I can peer a transit gateway
in Ohio and Northern Virginia if they exist.

Like the *deploy_transit_gateway_in_this_aws_region* variable, the
*transit_gateway_peering* variable also contains a short that in some
way correlates to the short cut in the
*deploy_transit_gateway_in_this_aws_region* variable.

The short cut in the *transit_gateway_peering* variable is the
*build_complete_mesh* option. Setting this variable to true enables
peering between all regions that have an AWS Transit Gateway that is
built by this solution. An illustration of this variable can be seen
below.

***Illustration of deploy_transit_gateway_in_this_aws_region variable***

```hcl-terraform 
variable "transit_gateway_peering" {
    type = map(bool)
    default = {
        build_complete_mesh         = true          # false
        ohio_n_virginia             = false         # true
        ohio_canada_east            = false         # true
        ohio_oregon                 = false         # true
        ohio_n_california           = false         # true
        oregon_n_california         = false         # true
        oregon_canada_east          = false         # true
        oregon_n_virginia           = false         # true
        oregon_n_sao_paulo          = false         # true
        oregon_n_london             = false         # true
        # n_california_canada_east  = false         # true
        n_california_n_virginia     = false         # true
        n_virginia_canada_east      = false         # true
        n_virginia_n_london         = false         # true
        n_virginia_sao_paulo        = false         # true
        london_n_ireland            = false         # true
        london_n_paris              = false         # true
        london_n_frankfurt          = false         # true
        london_n_milan              = false         # true
        london_n_stockholm          = false         # true
        ireland_n_paris             = false         # true
        ireland_n_frankfurt         = false         # true
        ireland_n_stockholm         = false         # true
        frankfurt_n_stockholm       = false         # true
        frankfurt_n_paris           = false         # true
        stockholm_n_paris           = false         # true
        mumbai_n_frankfurt          = false         # true
        mumbai_n_sao_paulo          = false         # true
        mumbai_n_tokyo              = false         # true
        mumbai_n_seoul              = false         # true
        mumbai_n_singapore          = false         # true
        mumbai_n_sydney             = false         # true
        singapore_n_sydney          = false         # true
        singapore_n_tokyo           = false         # true
        singapore_n_sao_paulo       = false         # true
        singapore_n_seoul           = false         # true
        sydney_n_seoul              = false         # true
        sydney_n_tokyo              = false         # true
        sydney_n_sao_paulo          = false         # true
        tokyo_n_seoul               = false         # true
        tokyo_n_sao_paulo           = false         # true
        paris_n_sao_paulo           = false         # true
        }
}

```

An example of how this variable is used in the *main.tf* is highlighted
below in white and underlined.
```hcl-terraform 

module "terraform-aws-fsf-tgw-peering-regions-n_virginia-n-canada_east" {
    source = "./peer_transit_gateways"
    count = ((var.deploy_transit_gateway_in_this_aws_region.all_aws_regions == true || (var.deploy_transit_gateway_in_this_aws_region.n_virginia== true && var.deploy_transit_gateway_in_this_aws_region.canada_east == true) ) && (var.transit_gateway_peering.n_virginia_canada_east == true|| var.transit_gateway_peering.build_complete_mesh == true) ? 1:0)
    providers = { 
        aws = aws.n_virginia 
    }
    # transit gateway being peered with account id
    peer_account_id = data.aws_caller_identity.first.account_id
    # transit gateway being peered with region
    peer_region = "ca-central-1"
    # transit gateway being peered with
    peer_transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-canada-montreal[**0**].transit_gateway_id
    # transit gateway requesting to be peered
    transit_gateway_id = module.terraform-aws-fsf-tgw-deployment-n_virginia[**0**].transit_gateway_id
}
```
```hcl-terraform 
variable "how_many_vpn_connections" {}
```

This variable tells the *create_transit_gateway* sub-module how many AWS
Site-2-Site VPNs to create.


# **Implementation Guide**

There are two categories of configurations for this transit gateway
solution; these are the Non-Infrastructure Deployment Configuration and
the Infrastructure Deployment Configuration.

Both configuration category takes place in the *variables.tf* file.
Please note that you can create a *terraform.tfvar* that makes
configuration easier.

**Non-Infrastructure Deployment Configuration**

Pre-deployment configuration is optional if you don't intend to share
the outputs with other Terraform modules.

If you intend to use the outputs.tf information in other Terraform
solutions like network deployer solution then you have to configure then
the pre-deployment configuration is mandatory.

If your requirements matches the latter then you have to configure the
backend.tf file with your backend configuration.

The default backend that is configured by this solution is AWS S3. You
can, however, bring your own backend.

***Illustration of the default backend.tf** **file ***

``` hcl-terraform 
terraform{
    backend "s3"{
    
    # Please populate with the name of the S3 bucket that holds the
    terraform.tfstate file for your transit_gateway\
    bucket = "my-terraform-state-bucket-name"
    
    # Please populate with the key name the terraform.tfstate file for your
    transit_gateway
    key = "my-terraform-state-bucket-name/transit-gateway/terraform.tfstate"
    
    # Please populate with the AWS Region for the S3 bucket that stores the
    terraform.tfstate file for your transit_gateway
    region = "us-east-2"
    
    }
}
```
**Infrastructure Deployment Configurations**

As stated previously, this solution can deploy a range of transit
gateways implementations which range from the deployment of a single
transit gateway to a globally meshed network of transit gateways that
are all managed by the AWS Network Manager.

The great thing about this solution is the only configuration required
exist within the variable.tf file. You are never required to configure
any items in the main.tf file.

The below guide provides detailed instructions on how to implement
different types of transit gateway implementations supported by this
solution.

**Deployment Option 1: Deploying A Single Transit Gateway with an AWS
Site-2-Site VPN**

By default, all variables in the *variables.tf* file is set to false.
Please do the following to deploy a single transit gateway in a
specified AWS Region.

**Step 1.**

Go to the *variables.tf* file and search for the variable
*deploy_transit_gateway_in_this_aws_region.* Once found, set true beside
the AWS Region where you would like to deploy the transit gateway.

```hcl-terraform
variable "deploy_transit_gateway_in_this_aws_region" {
    type = map(bool)
    default = {
        all_aws_regions         = false # true
        ohio                    = true # true
        n_virginia              = false # true
        oregon                  = false # true
        n_california            = false # true
        canada_east             = false # true
        ireland                 = false # true
        london                  = false # true
        stockholm               = false # true
        frankfurt               = false # true
        paris                   = false # true
        tokyo                   = false # true
        seoul                   = false # true
        sydney                  = false # true
        mumbai                  = false # true
        singapore               = false # true
        sao-paulo               = false # true
}
}
```

**Step 2.**

To enable to creation of an AWS Site-to-Site VPN, search for the
variable *create_site_to_site_vpn* and set true beside the AWS Region
where you would like to enable the AWS Site-to-Site VPN.

```hcl-terraform

variable "create_site_to_site_vpn" {
    type = map(bool)
    default = {
        ohio                = true
        n_virginia          = false
        oregon              = false
        n_california        = false
        canada_east         = false
        ireland             = false
        london              = false
        stockholm           = false
        frankfurt           = false
        paris               = false
        tokyo               = false
        seoul               = false
        sydney              = false
        mumbai              = false
        singapore           = false
        sao_paulo           = false
}
}

```

Step 3.

Given that you have enabled the creation of the site to site VPN, you
will now need to add the details for this VPN.

a.  Search for the variable *remote_site-public_ip* and add the public
    IP Address beside the AWS Region where the VPN is being created.
    This IP is the Public IP for your remote location which could be a
    data center or satellite office etc.

```hcl-terraform
# Please change the loop back address to the public IP address of your remote site
 variable "remote_site_public_ip"{
    type = map(string)
    default = {
        hq                  = "127.0.0.1"
        ohio                = "50.50.50.50"
        n_virginia          = "127.0.0.1"
        oregon              = "127.0.0.1"
        n_california        = "127.0.0.1"
        canada_east         = "127.0.0.1"
        ireland             = "127.0.0.1"
        london              = "127.0.0.1"
        stockholm           = "127.0.0.1"
        frankfurt           = "127.0.0.1"
        paris               = "127.0.0.1"
        tokyo               = "127.0.0.1"
        seoul               = "127.0.0.1"
        sydney              = "127.0.0.1"
        mumbai              = "127.0.0.1"
        singapore           = "127.0.0.1"
        sao-paulo           = "127.0.0.1"
    }
 }

```

b.  Search for the variable *how_many_vpn_connections* and set the
    number of VPN connections you would like to create to the above
    remote site. Please note that ECMP is enabled on your transit
    gateway by default and you should only add a number greater than
    one (1) if you intend to load balance across multiple tunnels across
    multiple AWS Site-to-Site VPNs.

For details on how to configure your on-premises network device on which
the VPN(s) are being terminated, please see this [instructional
post](https://aws.amazon.com/premiumsupport/knowledge-center/transit-gateway-ecmp-multiple-tunnels/).

```hcl-terraform
variable "how_many_vpn_connections"{
    default = **1
}
```

c.  Lastly, you will need to add the BGP ASN for the on-premises network
    to which you are creating the VPN to.

> To do this, search for the variable *remote_site_asn* and add the BGP
> ASN beside the AWS region in which the AWS Site to Site VPN is being
> created.

```hcl-terraform

variable "remote_site_asn" {
 type     = map(number)
 default  = {
     hq           = 65000
     ohio         = 65535
     n_virginia   = 65000
     oregon       = 65000
     n_california = 65000
     canada_east  = 65000
     ireland      = 65000
     london       = 65000
     stockholm    = 65000
     frankfurt    = 65000
     paris        = 65000
     tokyo        = 65000
     seoul        = 65000
     sydney       = 65000
     mumbai       = 65000
     singapore    = 65000
     sao-paulo    = 65000
  }
}

```

**Deployment Option 2: Peering Two Transit Gateways Deployed Across
Multiple AWS Regions**

Please follow the following steps to configure peering between two or
more transit gateways that are located in different AWS Regions.

**Step 1:**

The first step is to deploy the transit gateways if they are not already
deployed.

To do this, search for the variable
*deploy_transit_gateway_in_this_aws_region.* Once found, set true beside
the AWS Regions where you would like to deploy the transit gateway.

*Configuration Illustration*

```hcl-terraform

variable "deploy_transit_gateway_in_this_aws_region" {
    type = map(bool)
    default = {
        all_aws_regions         = false # true
        ohio                    = true # true
        n_virginia              = true # true
        oregon                  = false # true
        n_california            = false # true
        canada_east             = false # true
        ireland                 = false # true
        london                  = false # true
        stockholm               = false # true
        frankfurt               = false # true
        paris                   = false # true
        tokyo                   = false # true
        seoul                   = false # true
        sydney                  = false # true
        mumbai                  = false # true
        singapore               = false # true
        sao-paulo               = false # true
    }
}

```
**Step 2:**

Next, you will need enable peering for the regions in which your transit
gateways will be deployed or already have been deployed (by this
solution).

To do this, search for the variable *transit_gateway_peering* then
search for the peering configuration that matches the regions you
activated in step 1. Once found, set the boolean value to true.

*Configuration Illustration*

```hcl-terraform
variable "transit_gateway_peering" {
    type = map(bool)
    default = {
        build_complete_mesh             = false # true
        ohio_n_virginia                 = true # true
        ohio_canada_east                = false # true
        ohio_oregon                     = false # true
        ohio_n_california               = false # true
        oregon_n_california             = false # true
        oregon_canada_east              = false # true
        oregon_n_virginia               = false # true
        oregon_n_sao_paulo              = false # true
        oregon_n_london                 = false # true
        # n_california_canada_east      = false # true
        n_california_n_virginia         = false # true
        n_virginia_canada_east          = false # true
        n_virginia_n_london             = false # true
        n_virginia_sao_paulo            = false # true
        london_n_ireland                = false # true
        london_n_paris                  = false # true
        london_n_frankfurt              = false # true
        london_n_milan                  = false # true
        london_n_stockholm              = false # true
        ireland_n_paris                 = false # true
        ireland_n_frankfurt             = false # true
        ireland_n_stockholm             = false # true
        frankfurt_n_stockholm           = false # true
        frankfurt_n_paris               = false # true
        stockholm_n_paris               = false # true
        mumbai_n_frankfurt              = false # true
        mumbai_n_sao_paulo              = false # true
        mumbai_n_tokyo                  = false # true
        mumbai_n_seoul                  = false # true
        mumbai_n_singapore              = false # true
        mumbai_n_sydney                 = false # true
        singapore_n_sydney              = false # true
        singapore_n_tokyo               = false # true
        singapore_n_sao_paulo           = false # true
        singapore_n_seoul               = false # true
        sydney_n_seoul                  = false # true
        sydney_n_tokyo                  = false # true
        sydney_n_sao_paulo              = false # true
        tokyo_n_seoul                   = false # true
        tokyo_n_sao_paulo               = false # true
        paris_n_sao_paulo               = false # true
  }
}
```

If you require the creation of site to site VPN on the transit gateways
you deployed in this configuration then please follow the VPN creation
steps outlined in ***Deployment Option 1: Deploying A Single Transit
Gateway with an AWS Site-2-Site VPN* and follow steps 2-3 for each
region.**

**Deployment Option 3: Deploying a Globally Meshed Network of Transit
Gateways**

Deploying a globally meshed network of transit gateways is quite simple
with this solution. To do this, follow the steps outlined below.

**Step 1:**

Search for the variable *deploy_transit_gateway_in_this_aws_region.*
Once found, set true beside the option labeled *all_aws_regions.*

*Configuration Illustration*

```hcl-terraform

variable "deploy_transit_gateway_in_this_aws_region" {
    type = map(bool)
    default = {
        all_aws_regions         = true # true
        ohio                    = false # true
        n_virginia              = false # true
        oregon                  = false # true
        n_california            = false # true
        canada_east             = false # true
        ireland                 = false # true
        london                  = false # true
        stockholm               = false # true
        frankfurt               = false # true
        paris                   = false # true
        tokyo                   = false # true
        seoul                   = false # true
        sydney                  = false # true
        mumbai                  = false # true
        singapore               = false # true
        sao-paulo               = false # true
  }
}

```

**Step 2:**

Next, search for the variable *transit_gateway_peering* and look for the
option labeled *build_complete_mesh*. Set this option's boolean to true.

*Configuration Illustration*

```hcl-terraform

variable "transit_gateway_peering" {
    type = map(bool)
    default = {
        build_complete_mesh             = true # false
        ohio_n_virginia                 = false # true
        ohio_canada_east                = false # true
        ohio_oregon                     = false # true
        ohio_n_california               = false # true
        oregon_n_california             = false # true
        oregon_canada_east              = false # true
        oregon_n_virginia               = false # true
        oregon_n_sao_paulo              = false # true
        oregon_n_london                 = false # true
        # n_california_canada_east      = false # true
        n_california_n_virginia         = false # true
        n_virginia_canada_east          = false # true
        n_virginia_n_london             = false # true
        n_virginia_sao_paulo            = false # true
        london_n_ireland                = false # true
        london_n_paris                  = false # true
        london_n_frankfurt              = false # true
        london_n_milan                  = false # true
        london_n_stockholm              = false # true
        ireland_n_paris                 = false # true
        ireland_n_frankfurt             = false # true
        ireland_n_stockholm             = false # true
        frankfurt_n_stockholm           = false # true
        frankfurt_n_paris               = false # true
        stockholm_n_paris               = false # true
        mumbai_n_frankfurt              = false # true
        mumbai_n_sao_paulo              = false # true
        mumbai_n_tokyo                  = false # true
        mumbai_n_seoul                  = false # true
        mumbai_n_singapore              = false # true
        mumbai_n_sydney                 = false # true
        singapore_n_sydney              = false # true
        singapore_n_tokyo               = false # true
        singapore_n_sao_paulo           = false # true
        singapore_n_seoul               = false # true
        sydney_n_seoul                  = false # true
        sydney_n_tokyo                  = false # true
        sydney_n_sao_paulo              = false # true
        tokyo_n_seoul                   = false # true
        tokyo_n_sao_paulo               = false # true
        paris_n_sao_paulo               = false # true    
    }
}
```

Voila, you are done.

Please note that if you require the creation of site to site VPN on the
transit gateways being deployed then you will have to follow the VPN
creation steps outlined in ***Deployment Option 1: Deploying A Single
Transit Gateway with an AWS Site-2-Site VPN*** and follow steps 2-3 for
each region.

Lastly, please configure all the variables located in *[Tags]{.ul}*
segment of the variables.tf file. They will be used for tagging
throughout the solution.


# **Conclusion** 

In conclusion, this solution is designed and built to reduce the time
it takes to go from decision to deploy a globally meshed transit gateway network on AWS.

A customer can choose to deploy a globally meshed transit gateway network or a single transit gateway that is
specific to a single AWS Region. The network you deploy is directly
related to the knobs and switches that you have turned within the
solution.

Please have fun with this solution and feel free to provide feedback
where necessary.