# Transitive Architecture for Financial Services

```hcl-terraform 

Solution Created By:      Androski Spicer

Documentation Written By: Androski Spicer

Last Updated: May 2021

```

#


# Table of Contents

1. [About This Document 4](#about-this-document)

2. [Overview 4](#overview)

3. [Assumptions 6](#assumptions)

4. [Technical Overview 7](#technical-overview)

5. [The Transitive Network 7](#the-transitive-network)

5. [Shared Services & Spoke Network Fundamentals 12](#shared-services-spoke-network-fundamentals)

6. [Architectural Features 12](#architectural-features)

7. [Shared Services Network 14](#shared-services-network)

8. [Architectural Features 14](#architectural-features-1)

9. [Spoke VPC/ Network 17](#spoke-vpc-network)

10. [Architectural Features 17](#architectural-features-2)

11. [The Terraform Modules 21](#the-terraform-modules)

12. [The AWS Transit Gateway Repository and modules 21](#the-aws-transit-gateway-repository-and-modules)

13. [Orchestration-Modules Deep 50](#orchestration-modules-deep)

14. [Network Deployer Deployment Guide 54](#network-deployer-deployment-guide)

15. [Network Deployment Options 54](#network-deployment-options)

16. [Deployment Option Implementation Guide 56](#deployment-option-implementation-guide)

17. [Terraform Provider Prerequisites 56](#terraform-provider-prerequisites)

    A. [Account Paving Task Step by Step Guide 58](#account-paving-task-step-by-step-guide)

    B. [Deployment Options & Account Paving 60](#deployment-options-account-paving)

20. [Deployment Options & How to Deploy Them 62](#deployment-options-how-to-deploy-them)

    A. [**Deploying a Stand-alone Spoke VPC** 62](#deploying-a-stand-alone-spoke-vpc)

    B. **Deploying a Stand-alone Shared Services VPC with Centralized Resources** 67

    C. [**Deploying the Integrated Spoke VPC and Shared Services VPC with automated association with centralized DNS and centralized VPC Interface Endpoint resources** 70](#deploying-the-integrated-spoke-vpc-and-shared-services-vpc-with-automated-association-with-centralized-dns-and-centralized-vpc-interface-endpoint-resources)

    D. [**Deploying the Integrated Spoke VPC and Shared Services VPC with automated association with centralized DNS and centralized VPC Interface Endpoint resources plus automated integration with the global AWS Transit Gateway Solution.** 80](#deploying-the-integrated-spoke-vpc-and-shared-services-vpc-with-automated-association-with-centralized-dns-and-centralized-vpc-interface-endpoint-resources-plus-automated-integration-with-the-global-aws-transit-gateway-solution.)

21. [Conclusion 82](#conclusion)

# About This Document

The purpose of this document is to discuss a prescriptive solution that
deploys a global network architecture in accordance with AWS best
practices.

# Overview

The solution discussed in this document provides customers with a set of
opinionated Terraform modules that deploys and automates the
configuration of a global network on AWS.

Today, this solution builds three key network types;

-   **Layer Three/Transitive Network(s)**

    -   Customers have control over the number of transit gateways that
        are created and where they are created.

-   **Shared Services Network(s)**

    -   The shared services network should be used to host those
        services that are fundamental to the successful operation of the
        entire network.

    -   Today, this network comes with a centralized AWS VPC Interface
        endpoint solution and a centralized DNS solution.

-   **Spoke Networks**

    -   These networks host customers application teams workloads and
        are seamlessly integrated with each of the networks outlined
        above.

A fourth network type will be introduced in the next iteration of this
solution; that is, the security network that gives customers the option
of leveraging key AWS security services like AWS Firewall Manager and
AWS Network Firewall or use third party tools like Palo Alto and
Fortinet.

This solution is designed to answer four main category of networking
questions that customers generally have when approaching the topic of
networking on AWS.

These are:

-   How should we think about implementing and configuring a transitive
    network on AWS and what are the best practices

-   How can we introduce automation to ensure that all VPCs integrates
    with this transitive network

-   How should I think about egress to AWS services and how should this
    be implemented

-   What are our options for DNS; that is, what are our options for
    deploying DNS within AWS and integrating this with our DNS solution
    on-premises

As for traffic and routing, this solution provides automated
configuration for each of the follow:

-   East - West packet inspection via a security VPC if one is available

-   No East -- West packet inspection. Traffic flow directly to the DNS
    network, Shared Services network and on-premises.

-   Traffic flow to a shared services or DNS VPC without traffic
    inspection if no security services VPC is available

-   Intentional VPC & transit gateway route table configuration with no
    automatic route propagation to the default route table

-   VPC Isolation

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

# **Technical Overview** 

This section dives deeper into the three key network types that are
built by this solution. These networks are as follows:

-   **Layer Three/Transitive Network(s)**

-   **Shared Services Network(s)**

-   **Spoke Networks**

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



# Shared Services & Spoke Network Fundamentals 

### 

### Architectural Features

All VPCs deployed by this solution comes with some fundamental features.
That is, they are created with three subnets types; private/aws-routable
subnets, public/externally-routable subnets and transit gateway subnets.

Accompanying these subnets are matching route tables with specific
routing configuration based on the subnet type.

A gateway VPC endpoint is also created for the Amazon S3 and DynamoDB
service. Several VPC security groups are also created. The creation of
these security groups is controlled by a Boolean map and the ports by
another.

Today, a customer can create the following security groups:

-   Database

-   Web Application

-   Apache Spark

-   Kafka

-   Elastic Search

The ports enabled in each security group allows for secured access to
the resources being protected by the security group.

Each spoke account receives an AWS EventBridge EventBus, a set of rules
and an AWS Lambda function that performs specific network tasks.

Networking tasks like private hosted zone sharing, transit gateway route
table association and configuration is handled by this function.



# Shared Services Network 

### Architectural Features

The shared services network also the shared services VPC has one
purpose. That is, it is used to host AWS services and other applications
that should be centrally distributed to all networks it is connected to.
It is connected to all VPCs and allowed networks on-premises.

Today, this deployment comes with a centralized interface endpoint
solution for all created endpoints and a centralized DNS solution.

In the transitive network, all spoke networks and on-premises networks
knows how to reach the shared services network. This is accomplished by
leaking routes to these route tables respectively.

Centralized VPC Interface Endpoints

The shared services network module contains a reference to module call
the interface endpoint module. The shared services module passes a flag
to the interface endpoint module that asserts that the network being
created is a shared services network.

This assertion allows the interface endpoint module to not only create
the specified endpoints but it also builds the mechanisms that makes
centralization possible.

That is, self-managed private hosted zones are created for each
interface endpoint. A Lambda function is also created.

This function is used to respond to events on the event bus for newly
created spoke VPCs that need to get access to these centralize
endpoints.

The function takes care of authorizing the VPC for access to each of
these hosted zones then adds an event to the spoke VPC event bus that is
picked up by an AWS Lambda function that completes the association
handshake, by formally issuing an association request to each of the
available private hosted zones for each of the interface endpoints that
exist.



Centralized DNS

The centralized DNS solution leverages AWS Route 53 private hosted
zones, Route 53 Resolvers, AWS EventBridge event bus and AWS Lambda to
allows VPCs connected to the transitive network and on-premises
resolvers resolve domains that are specific to AWS.

It also allows AWS resources to forward requests for on-premises domains
to the on-premises resolvers.

The shared services network comes with an AWS Route 53 resolver inbound
and outbound endpoint configuration.

Within the event bus that supports network orchestration within the
shared services VPC is a rule for private hosted zone manipulation.

Each spoke network can be created with a private hosted zone. Each spoke
private hosted zone creation triggers an event for the association of
that private hosted zone with the shared services VPC.

The spoke authorizes the shared services network and writes the
association event to the shared services network event bus. The network
operations lambda function then completes the association by making an
association request. This function uses a flag to then create an AWS
Route 53 resolver rule for the domain or sub-domain. This rule is only
created if it doesn't already exist.

Once a rule is created, it then shared the AWS Organization that the
shared service network belongs to. This allows all newly created spoke
network to access this shared resource.

Once this process is completed, all VPCs and resolvers on-premises will
be able to forward their resolution request to inbound resolver
endpoints. Once received, the resolver for the shared services VPC will
then provide a response to the requester.

Please note that on-premises resolvers should be configured to forward
DNS queries for AWS specific domains to the inbound resolver endpoint
IPs of the shared services VPC/network.

# Spoke VPC/ Network 

### Architectural Features

The spoke VPC Terraform modules creates a VPC that integrates seamlessly
with the above mentioned transit gateway solution.

This module creates a VPC that is ready to host financial services
workloads. It does this by putting policies and restrictions in place
that reduces the attack surface within the VPC.

This is accomplished by ensuring that the VPC has:

-   No egress to the Internet or infrastructure that would provide this
    kind of access

-   No Site-to-Site VPN Infrastructure present

-   VPC Endpoint are configure with policies to provide access to AWS
    resources specific to the account

-   Custom Security Groups are created for each subnet type and only
    allow access between specific on-premises IP ranges and the VPC

The Terraform solution that builds the spoke VPC solution consists of
the following modules:

-   **The Spoke VPC Module**

    -   This module takes a CIDR range as input and creates an AWS VPC
        with DNS support and hostname enabled

    -   Sub modules for DHCP and VPC Flow logs are also present in this
        module. The DHCP module allows customers to:

        -   Create a standard/default DHCP Option set with all the
            native configuration for DNS etc.

        -   Customers also have the option to create custom DHCP Option
            Set where they can specify their DNS servers, NetBIOS
            configuration, etc.

    -   The spoke VPC module contains references to the DHCP module and
        builds it according to how its configured.

    -   The VPC FlowLogs sub module builds all the pieces necessary for
        FlowLogs to work. That is, it creates:

        -   The CloudWatch Log Group where all VPC FlowLogs will be sent

        -   The CloudWatch IAM Role and Policy

        -   The FlowLogs resource in which the traffic type is specified
            as well as the above mentioned CloudWatch infrastructures.

    -   The Spoke VPC modules are built with ease of use in mind as such
        contains automation that makes it easy to perform tasks such as
        association with private hosted zones that exist in the shared
        services vpc that exist in a completely different VPC.

        -   That said, this module exposes a submodule that allows a
            customer to automatically associate the VPC with a
            centralized VPC Interface Endpoint configuration that exist
            in another account, that is the shared services or network
            services account.

        -   This task is performed by an AWS Lambda function. The
            function makes a RESTful API call to an API in the shared
            services/network services account. The API discovers all the
            AWS Route53 private hosted zones that were created for a VPC
            Interface Endpoint.

        -   Up on discovery of these private hosted zones, an
            association authorization request is made for each private
            hosted zone with the VPC ID that was passed by the AWS
            Lambda function that made the request.

        -   Once the authorization request is complete, the API returns
            the Hosted Zone IDs to the Lambda function. The Lambda
            function then performs an association request. This
            completes the steps necessary for the private hosted zone
            association.

        -   Please note that this is optional.

-   **The Subnet Module** builds three type of subnet;
    private/non-routable, public/externally-routable and transit gateway
    subnets.

    -   Private/Non-routable subnets are only routable inside the AWS
        VPC.

    -   Public/Externally-routable Subnets can route within the VPC,
        outside the VPC to VPCs attached to the AWS Transit Gateway and
        to on-premises networks.

    -   Transit Gateway Subnets has a CIDR range of /28 and are created
        for the sole purpose of hosting transit gateway attachment
        elastic network interfaces (ENIs).

    -   The Subnet module contains the following sub-modules:

        -   Route Table Module

            -   Creates three route tables; private/non-routable,
                public/externally-routable and transit gateway route
                table

            -   Subnets are then associated with the newly created route
                tables. That is:

                -   Private/non-routable subnets are associated with the
                    Private/non-routable route table

                -   Public/externally-routable subnets are associated
                    with the Public/externally-routable route table

                -   Transit gateway subnets are associated with the
                    Transit gateway route table

        -   Transit Gateway Association sub-module

            -   Creates AWS Transit Gateway Attachment requests

            -   All Transit Gateway subnets are used in this request as
                these subnets are created in at least two AWS
                Availability Zones.

        -   Add Route sub-module

            -   Today, this module is used to configure the
                Public/Externally-routable route tables with a default
                route to the transit gateway if one is available.

-   **Security Group Module**

    -   This module creates five AWS VPC Security Groups. Four of these
        security groups are special purpose security groups created for
        public/externally-routable workloads. These security groups are
        as follows:

        -   Web Security Group:

            -   Only allows inbound request on port 443 from on-premises
                CIDR ranges.

            -   These summarized CIDR ranges are specified in an array.
                Terraform loops through this array to create the inbound
                rules

        -   Database Security Group:

            -   This security group contains inbound rules that allows
                access on ports that map to each of the popular database
                engines. That is SQL Server, MySQL, Postgres SQL and
                Oracle. Inbound access is only allowed from an
                on-premises list of IPs.

        -   Apache Spark Security Group

            -   This security group contains inbound rules that only
                allow access for Apache Spark on secured ports. Again,
                inbound access is only allowed from on-premises CIDR
                ranges

        -   Kafka & Zoo Keeper Security Group

            -   Contain inbound rules for both Kafka and Zoo Keeper

        -   Elasticsearch Security Group

            -   Cycles through an object map to create inbound rules for
                Elasticsearch from the customer's on-premises CIDR
                ranges

-   **VPC Endpoint Module**

    -   For spoke VPCs, this module creates two mandatory VPC endpoints.
        They are as followed:

        -   An Amazon VPC Endpoint for Amazon S3. This endpoint is
            created with an endpoint policy that only allows resource
            specific API calls to Amazon S3 buckets that belongs to the
            account the account in which the VPC Endpoint was created.

        -   It is recommended that the S3 bucket policy be created in
            such a way that it only allows VPC endpoints to perform
            S3:GetObject API calls. All other IAM principals should only
            be allowed to perform list and put operations.

        -   This will further reduce the ability for objects to moved
            outside of the account.

        -   An Amazon Endpoint is also created for DynamoDB

# **The Terraform Modules** 

It's important to note once again that this opinionated solution is
written in Terraform. The Terraform modules built by this solution is
stored in GitHub repositories (repos). There are two main repos; that
is, one for the AWS Transit Gateway Terraform modules and another for
the Terraform modules that creates the different network types on AWS.

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
####***\_create_transit_gateway***

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

**The AWS VPC Deployment Repository and Modules**

The VPC deployment solution is made up sixteen modules that all work
together to give customers the ability to deploy two types of VPCs in
any AWS Region. That is, a spoke VPC and a shared services VPC. The
spoke VPC will automatically integrate itself with all centralized
resources that are available in the shared services VPC. This includes
the AWS Transit Gateway solution mentioned above, the shared services
centralized DNS solution and the shared services centralized VPC
Interface Endpoint solution.

The sixteen modules that make up this solution are divided into two
categories; feature-modules and orchestration-modules. The feature
modules are built to deliver specific AWS service features. Some
feature-modules contain configurations for deploying a stand-alone
version of the feature or deploying all the components that makes it
possible to centrally share this service feature with all spoke VPCs
that are connected to the same layer three hub.

The deployment decision is managed by Boolean object maps and an
awareness of the type of VPC that is being created.

The orchestration-modules are well structured and contains well-tailored
module configurations that tells each feature-module how it should
deploy the feature being requested.

Orchestration-modules are split into two types; that is, the spoke
orchestration-module, which formally defined in the repository as
***\_aws-financial-services-framework-deploy-spoke-vpc*** and the
shared-services orchestration-module, which is formally defined in the
repository as
\_***aws-financial-services-framework-deploy-shared-services-vpc.***

The structure of the repository is illustrated below.

***Illustrated High Level Structure of the AWS VPC Deployment
Repository***
```hcl-terraform
.
├── _aws-financial-services-framework-add-routes
│
├──_aws-financial-services-framework-amazon-vpc-endpoints-for-terraform
│
├──_aws-financial-services-framework-amazon-vpc-flow-logs-for-terraform
│
├──_aws-financial-services-framework-amazon-vpc-route-table-for-terraform
│
├──_aws-financial-services-framework-amazon-vpc-subnets-for-terraform
│
├──_aws-financial-services-framework-deploy-shared-services-vpc
│
├──_aws-financial-services-framework-deploy-spoke-vpc
│
├──_aws-financial-services-framework-dhcp-terraform
│
├──_aws-financial-services-framework-dns-private-hosted-zones
│
├──_aws-financial-services-framework-dns-resolvers
│
├──_aws-financial-services-framework-eventbridge-network-bus
│
├──_aws-financial-services-framework-security-group-for-terraform
│
├──_aws-financial-services-framework-spoke-vpc-for-terraform
│
├──_aws-financial-services-framework-transit-gateway-association-spoke
│
├──_aws-financial-services-network-ops-lambda-fn
│
├──_aws-financial-services-network-ops-put-event-lambda-fn
│
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── backend.tf
├── provider.tf
├── outputs.tf
```
Let's take a closer look at the feature-modules.

***Feature-Modules Deep Dive***

Feature-modules are used to deploy AWS services and AWS service
features. There are two categories of feature-modules;
orchestration-support feature modules and service-delivery feature
modules.

***Orchestration-support feature-modules***

The orchestration-support feature modules are used to wire up the
building blocks that are required to deploy enterprise type solutions
like centralized DNS and centralized interface endpoints and transit
gateway route table configuration.

These modules include;
```hcl-terraform
├──_aws-financial-services-framework-eventbridge-network-bus
├──_aws-financial-services-network-ops-lambda-fn
├──_aws-financial-services-network-ops-put-event-lambda-fn
```
Let's take a closer look at each

***aws-financial-services-framework-eventbridge-network-bus***

-   The ***\_aws-financial-services-framework-eventbridge-network-bus***
    feature-module is used to create an AWS EventBridge EventBus and
    EventBus Rules which work in synchrony to support the coordination
    of network tasks between the shared services VPC and all spoke
    VPC(s).

-   This AWS EventBus is also used to coordinate network tasks within
    each of the VPC type.

-   These tasks includes

    -   The attachment of each AWS VPC to the right AWS Transit Gateway
        route table based on the tags assigned to that VPC. For example,
        a spoke VPC with the tag dev/development is attached the
        development route table or a shared services VPC with the tag
        shared services is attached to the Shared-Service/shared
        services is associated with the AWS Transit Gateway shared
        services route.

    -   Associated each newly created VPC with the private hosted zones
        that forms the building blocks of the centralized interface
        endpoint solution.

    -   Associating the shared services VPC with all spoke private
        hosted zones

    -   Creation and centralization of AWS Route53 resolver rules

***aws-financial-services-network-ops-lambda-fn***

-   This module deploys a Lambda function that is invoked by the event
    bus that is created by the
    ***\_aws-financial-services-framework-eventbridge-network-bus***
    feature-module.

-   This function takes as input the event data. The tasks to be
    performed is denoted in the event bus source field. Below are a list
    of source definition and a brief explanation of the task to be
    performed.

    -   \"source\":
        \[\"aws-fsf-network-ops.associate-with-spoke-private-hosted-zone-event\"\]

        -   This source definition results in the shared services VPC
            being associated with the private hosted zone that was
            created for a spoke VPC in a spoke account.

    -   \"source\":
        \[\"aws-fsf-network-ops.route-table-associate-n-route-propagation-event\"\]

        -   Results in the association of a VPC with a transit gateway
            route table and routes statically and dynamically added to
            all the right tables.

        -   This is driven by the tags assigned to the VPC

    -   \"source\":
        \[\"aws-fsf-network-ops.interface-endpoints-association-event\"\]

        -   The event is sent to the event bus in the shared services
            account. The event also includes the VPC ID of the
            requesting VPC and the AWS Region where the VPC is deployed.

        -   The shared services VPC authorizes the requesting VPC for
            association with private hosted zones that front ends each
            available interface endpoint. Once authorized the hosted
            zone Id is sent to the requesting VPC event bus.

    -   \"source\":
        \[\"aws-fsf-network-ops.interface-endpoints-association-completion-event\"\]

        -   This event results in the completion of the private hosted
            zone association with the requesting VPC.

        -   The lambda function completing the association by looping
            through the list of hosted zones that were sent in the
            event. It uses each hosted zone Id in an AWS Route 53 API
            call. The API being used is
            *associate_vpc_with_hosted_zone().*

    -   \"source\":
        \[\"aws-fsf-network-ops.dns-resolver-rule-association-request-event\"\]

        -   This event is sent within the account of the VPC that is
            being created. It lists all available resolver rules that
            have been shared with the account. It filters this list then
            uses the AWS Route53 Resolver Rule API to associate the VPC
            with the resolver rule(s).

***aws-financial-services-network-ops-put-event-lambda-fn***

-   This module deploys an AWS Lambda function that is triggered only by
    Terraform as different stages of the build process. Invocations are
    made inside the orchestration-modules and inside some
    feature-modules like the private hosted zone module that's used to
    deploy one or more private hosted zones.

-   This function adds network coordination events to the AWS
    EventBridge EventBus in either the spoke or shared services account.

***Service-Delivery Feature-Modules***

The service-delivery feature-modules directly results in the deployment
of an AWS VPC features or AWS Transit Gateway features.

There are eleven modules in this category. They are as follows:

```hcl-terraform
├──_aws-financial-services-framework-add-routes
│
├──_aws-financial-services-framework-amazon-vpc-endpoints-for-terraform
│
├──_aws-financial-services-framework-amazon-vpc-flow-logs-for-terraform
│
├──_aws-financial-services-framework-amazon-vpc-route-table-for-terraform
│
├──_aws-financial-services-framework-amazon-vpc-subnets-for-terraform
│
├──_aws-financial-services-framework-deploy-shared-services-vpc
│
├──_aws-financial-services-framework-deploy-spoke-vpc
│
├──_aws-financial-services-framework-dhcp-terraform
│
├──_aws-financial-services-framework-dns-private-hosted-zones
│
├──_aws-financial-services-framework-dns-resolvers
│
├──_aws-financial-services-framework-security-group-for-terraform
│
├──_aws-financial-services-framework-spoke-vpc-for-terraform
│
├──_aws-financial-services-framework-transit-gateway-association-spoke

```
Let's take a closer look at each.

***aws-financial-services-framework-add-routes***

The "*aws-financial-services-framework-add-routes*" feature-module
configures the route table for the VPC that's being created. The route
table configuration centers around the transit gateway if one is
available. That is, the module takes as input a list of CIDR ranges that
should be added as destination CIDRs and an AWS Transit Gateway Id as
the target for traffic that's destined for the provided CIDR ranges.

Within the *variables.tf* file are two variables of type list that is
labeled. Their names are "*tgw_aws_route_destination*" and
"*tgw_external_route_destination*". By default these lists contains an
IP/CIDR that would create a default route in the VPC route table.
Customers can change this IP to reflect a customized list. Future
versions of this solution will use prefix lists.

*An example of the default configuration.*
```hcl-terraform 
variable "tgw_aws_route_destination" {
    description = "Holds the ID of the route table for aws_routable subbnets"
    default = ["0.0.0.0/0"]
}


variable "tgw_external_route_destination" {
    description = "Holds the ID of the route table for externally_routable subbnets"
    default = ["0.0.0.0/0"]
}
```

***aws-financial-services-framework-amazon-vpc-endpoints-for-terraform***

This feature-module is deploys both gateway and interface endpoints to
the VPC being created or updated.

Today, the endpoints that are created are as follows:

-   AWS S3

-   AWS DynamoDB

-   AWS EC2

-   AWS ECS

-   AWS SNS

-   AWS SQS

-   AWS Secrets Manager

-   AWS Key Management Service

-   AWS Systems Manager

-   AWS Systems Manager Messages

-   AWS EC2 Messages

-   AWS ECS Telemetry

-   AWS ECS Agent

-   AWS STS

The creation of these endpoints is controlled by Boolean map that is
labeled "endpoints". Customers control the endpoints to deploy by
switching the Boolean flag for the endpoint name to "*true*".

###*Example of variable*
```hcl-terraform 

variable "endpoints" {
    type = map(bool)
    default = {
        s3_gateway          = false
        dynamodb            = false
        secrets_manager     = false
        kms                 = false
        ec2                 = false
        ec2_messages        = false
        ecs                 = false
        ecs_agent           = false
        ecs_telemetry       = false
        sts                 = false
        sns                 = false
        sqs                 = false
        ssm                 = false
        ssm_messages        = false
    }
}
```

It is important to note that customers never interact directly with
feature-models. Instead, they pass in variable information from the
orchestration-modules to the feature modules.

That said, the default deployment action for the spoke orchestration
module results in only gateway endpoints being created. This assumes
that a shared services VPC exist. However, if a customer does not have a
shared services VPC with a centralized endpoint solution, then a
customer can deploy all the endpoints by changing the Boolean flag from
*false* to *true*.

The shared services orchestration-module default configuration creates
all VPC endpoints in the shared services VPC. The shared services
orchestration-module passes in an extra set of variables that tells this
module to deploy all the building blocks required to share the interface
endpoints with all VPCs that are created in accounts that belong to the
same AWS Organizations as the shared services account.

The variables that are passed in by the shared service orchestration
module are as follows:

```hcl-terraform
# Decision to create AWS Route 53 Private Hosted Zones
#------------------------------------------------------------------------------
variable "create_private_hosted_zones_for_endpoints" {
    description = "A Boolean flag to enable/disable DNS support in the VPC. Default's true."
    type = bool
    default = true
    validation {
        condition = (var.create_private_hosted_zones_for_endpoints == true || var.create_private_hosted_zones_for_endpoints == false )
        error_message = "DNS Support flag must be either true or false."
    }
}

```

```hcl-terraform

# Enable Private DNS
#------------------------------------------------------------------------------
variable "enable_private_dns" {
    description = "A Boolean flag to enable/disable DNS support in the VPC. Default's true."
    type = bool
    default = false
    validation {
        condition = (var.enable_private_dns == true || var.enable_private_dns == false )
        error_message = "DNS Support flag must be either true or false."
    }
}


```

These two variables control all the tasks required to centralize these
endpoints. *"create_private_hosted_zones_for_endpoints"* must be set to
true and "*enable_private_dns*" must be set to false to trigger the
deployment of the centralized solution.

Within this module is a sub-module called
"*interface_endpoints_private_hosted_zones*". It creates the AWS Route
53 Private Hosted Zones that front-ends each interface endpoints that
are created.

Newly created VPCs trigger association by adding an event to the shared
services AWS EventBus. This event then triggers the process that results
in this VPC being associated with the private hosted zone.

Please note that your shared services VPC must be connected to a layer 3
hub and all other VPCs must be able to communicate with the shared
services VPC. This satisfies the networking requirements for centralized
access to these endpoints.

***aws-financial-services-framework-amazon-vpc-flow-logs-for-terraform***

As the name suggests, the
*aws-financial-services-framework-amazon-vpc-flow-logs-for-terraform*
module enables VPC Flowlogs for your VPC. It's enabled by default.

That said, this module creates the following:

-   CloudWatch Log Group

    -   Acts a destination for the logs that are recorded

-   CloudWatch IAM Role and Policy

-   Enable Flowlog on the VPC

    -   Captures ALL Traffic

***aws-financial-services-framework-amazon-vpc-route-table-for-terraform***

The
*aws-financial-services-framework-amazon-vpc-route-table-for-terraform*
module creates three AWS VPC route tables. They are:

-   AWS Routable/Private Route Table

    a.  By default this route table only contains a local route. A
        transit gateway route can be added if needed

    b.  AWS Routable/private subnets are associated to this route table

-   Externally Routable/Public Route Table

    a.  Contains a local route and a route to an AWS Transit Gateway if
        this VPC integrates with the transit gateway solution mentioned
        in the prior section.

    b.  Externally routable/public subnets are explicitly associated
        with this route table

-   Transit Gateway Route Table

    a.  Contains a local route

    b.  Only transit gateway subnets are attached to this route table

Subnet IDs are taken as inputs as they are automatically associated with
the right route table. The subnet IDs are provided by the
*aws-financial-services-framework-amazon-vpc-subnets-for-terraform.*

***aws-financial-services-framework-amazon-vpc-subnets-for-terraform***

The subnet module or
*aws-financial-services-framework-amazon-vpc-subnets-for-terraform*
creates three category of subnets. These are as follows:

-   AWS Routable/Private Subnets

-   Externally Routable/Public Subnets

-   Transit Gateway Route Subnets

    a.  This subnet is created to hold the attachment interfaces for the
        transit gateway(s) that will interact with the VPC to which this
        subnet belongs.

The IP ranges that are used to create these subnets are located in a
variable of type list. This module spreads the IP space across all
available Availability Zone in the AWS Region.

Customers do not have to specify the Availability Zone ID. This module
pulls it and assigns the subnets accordingly.

Up on a successful deployment, this module publishes the Subnet IDs as
outputs. An output that is used by the route table and endpoints
modules.

***aws-financial-services-framework-dhcp-terraform***

*The aws-financial-services-framework-dhcp-terraform* module is allows
customers to explore all the options that are available to them when
creating a DHCP Option set within AWS.

Customers can chose to create a default option set or they can choose to
create a customized option set in which they are specify the hostname,
DNS servers, NETBIOS domain name servers, NTP servers, etc.

DHCP option set type is controlled by a Boolean map with the name
"*create_dhcp_options*".

Please note the following:

-   "*var.create_dhcp_options.dhcp_options*" is always set to true and
    customers are not allowed to turn this off.

-   "*var.create_dhcp_options.custom_dhcp_options*" is flexible and can
    be switched from true to false and vice versa.

    -   "*var.create_dhcp_options.custom_dhcp_options = false*" results
        in the default DHCP Option Set being deployed

    -   "*var.create_dhcp_options.custom_dhcp_options = true*" results
        in a custom DHCP Option Set being deployed. The *variables.tf*
        file contains several variables that are used in the creation of
        the custom DHCP Options.

*Example of variable*
```hcl-terraform
variable "create_dhcp_options" {
    type = map(bool)
    default = {
        dhcp_options = true
        custom_dhcp_options = false
    }
}
```


```hcl-terraform
# Custom DHCP Options configuration parameters.
#---------------------------------------------------------------------------------------------------------------
# (Optional) the suffix domain name to use by default when resolving non Fully Qualified Domain Names.
# In other words, this is what ends up being the search value in the /etc/resolv.conf file.
# Domain for Amazon Provided DNS

variable "custom_domain_name" {
	default = "example.com"
}


variable "domain_name_servers" {
	default = ["127.0.0.1”,"10.0.0.2"]
}

variable "ntp_servers" {
	default = ["127.0.0.1"]
}


variable "netbios_name_servers" {
	default = ["127.0.0.1"]
}


variable "netbios_node_type" {
	default = 2
}
```

***aws-financial-services-framework-dns-private-hosted-zones***

The *aws-financial-services-framework-dns-private-hosted-zones* module
deploys AWS Route 53 Private Hosted Zones(s). These private hosted zones
can be optionally associated with the shared services VPC if one exists.

This module can create one or as many as is permissible by the AWS Route
53 API in a single deployment. The number of private hosted zones that
are created up on deployment is controlled by a variable list that is
labeled "*private_hosted_zone_name*".

*Example of variable*

```hcl-terraform


variable "private_hosted_zone_name"{
    type = list(string)
    default = ["anaconda.aws-fsf-corp.com"]
}

```

The number hosted zone created is dependent on the hosted zones that are
located inside this list.

The creation of any hosted zone is dependent on the boolean map labeled
"*route53_acts*". Specifically,
"*var.route53_acts.create_private_hosted_zone*". Enabling this to be
true instructs Terraform to create the hosted zone(s) located in the
variable "*private_hosted_zone_name".*

*Example of variable*
```hcl-terraform

variable "route53_acts" {
    type = map(bool)
    default = {
        create_private_hosted_zone = true
        share_forwarding_rule_with_aws_organization = true
    }
}

```

***aws-financial-services-framework-dns-resolvers***

This module creates AWS Route 53 Resolver inbound and outbound
endpoints. It takes as input the outputted subnet ID from the
"*aws-financial-services-framework-amazon-vpc-subnets-for-terraform*"
module. The number of endpoints, whether inbound or outbound depends on
the number of subnet IDs that are returned. That said, a minimum of two
endpoints are created across two different availability zones.

AWS Route 53 Resolver query logging is not enabled by default.

***aws-financial-services-framework-security-group-for-terraform***

The *aws-financial-services-framework-security-group-for-terraform*
module creates the following security groups:

-   Database

-   Web Application

-   Apache Spark

-   Kafka

-   Elastic Search

Security group creation is controlled by the variable
*security_grp_traffic_pattern*. This is a boolean map that allows
customers to enable the security group they want by simply adding *true*
to the security they want. Security groups can be enabled and disabled
at any point in the VPC life cycle.

*Example of variable*

```hcl-terraform

variable "security_grp_traffic_pattern" {
    type = map(bool)
    default = {
        database            = true
        web                 = true
        kafka_zookeeper     = false
        elasticsearch       = false
        apache_spark        = false
    
    }
}

```
This module creates two categories of security groups; external and
internal. External security groups allows entities that are external to
the VPC to initiate traffic to resources inside the VPC on ports
specified.

External security groups allows access from a specific set of IP ranges.
These IP ranges are declared and stored inside a Terraform list
variable. This variable is labeled "*on_premises_cidrs*" and can be
found in the *variables.tf* file for this module.

*Example of variable*

```hcl-terraform

# On-premises IP Range to be added to the spoke VPC security group
#------------------------------------------------------------------------------
variable "on_premises_cidrs" {
    description = "On-premises or non VPC network range"
    type = list(string)
    default = [ "172.16.0.0/16", "172.17.0.0/16”,"172.18.0.0/16”, "172.19.0.0/16”, "172.20.0.0/16”, "172.22.0.0/16" ]
}


```

This variable list will be replaced by an AWS customer managed prefix
list in the next version release.

***aws-financial-services-framework-spoke-vpc-for-terraform***

The "*aws-financial-services-framework-spoke-vpc-for-terraform*" module
is used to create an IPv4 VPC that has DNS hostname and DNS support
enabled by default. These features cannot be disabled as Terraform
validation rules control the behavior of the variables that supports the
enablement of these features.

*Example of variable*
```hcl-terraform


# DNS_Support Bool Variable. This is used in the DHCP Option Set for the VPC
#------------------------------------------------------------------------------
variable "dns_support" {
    description = "A boolean flag to enable/disable DNS support in the VPC. Default's true."
    type = bool
    default = true
    validation {
        condition = (var.dns_support == true)
        error_message = "DNS Support flag must be either true or false."
    }
}


# DNS_Hostname Bool Variable. This is used in the DHCP Option Set for the VPC
#------------------------------------------------------------------------------
variable "dns_host_names" {
description = "A boolean flag to enable/disable DNS hostnames in the VPC."
    type = bool
    default = true
    validation {
        condition = (var.dns_host_names == true)
        error_message = "DNS Hostname flag must be either true or false."
    }
}



```

***aws-financial-services-framework-transit-gateway-association-spoke***

The *aws-financial-services-framework-transit-gateway-association-spoke*
module is fundamental in the interactions between all VPCs and the
transit gateways outlined in the AWS Transit Gateway solution section of
this document.

This module natively submits an AWS Transit Gateway attachment request
to a transit gateway if one exist. Please note that the automated
request is only made if the transit gateway deployed the transit gateway
solution outlined in this document.

Once the attachment request is successful, the details of the attachment
and transit gateway are passed as event data to an AWS Lambda function
that is triggered by this module.

AWS Transit Gateway only allows the manipulation of the transit gateway
route table from within the account where the transit gateway exists.

That said, the AWS Lambda function that is triggered by this module,
takes the event data and writes it to the AWS EventBus that handles
networking events in the account where the transit gateway lives.

The AWS Lambda function that this module uses to trigger the route table
configuration and route propagation is built by the
*aws-financial-services-network-ops-put-event-lambda-fn* module.

The execution of this entire module, that is the
*aws-financial-services-framework-transit-gateway-association-spoke*
module is controlled by boolean flags for two Terraform variables. These
are "*transit_gateway_subnets_exist*" and
"*create_transit_gateway_association*". They both have to be true for
this module to be executed. These variables can be found in this modules
*variable.tf* file.

*Example of variables*

```hcl-terraform


variable "transit_gateway_subnets_exist" {
    default = true
    validation {
        condition = (var.transit_gateway_subnets_exist == true || var.transit_gateway_subnets_exist == false)
        error_message = "Transit_gateway_subnets_exist can either be true or false."
    }
}


variable "create_transit_gateway_association" {
    default = true
    validation {
        condition = (var.create_transit_gateway_association == true || var.create_transit_gateway_association == false)
        error_message = "Create_transit_gateway_association can either be true or false."
    }
}


```

It is important to note that this module, like all other
service-delivery module is obfuscated from the user.

These modules are configured by variables passed in from the
orchestration-modules.

# **Orchestration-Modules Deep**

Orchestration-modules are declarative in nature and provides a simple,
well structured set of module references that reliably deploys a network
of integrated VPCs. This integration results in a global network of hub
and spoke networks.

Orchestration-modules brings to life all feature set that lives within
the all feature-modules. Feature-modules are not directly configured by
Customers. Instead, configuration variables are passed from
orchestration modules to all feature modules. This is done by creating a
terraform module reference then add values to the variables according to
what is required.

Each module reference inside the orchestration-module works together to
create VPCs that are consistent with AWS best practices.

Orchestration-modules consist of two Terraform sub-modules. These
sub-modules are preconfigured to produce two types of VPCs.

The VPC types are:

1.  Shared Services VPC

    -   *aws-financial-services-framework-deploy-shared-services-vpc*

2.  Spoke VPC

-   *aws-financial-services-framework-deploy-spoke-vpc*

Let's take a closer look at each of these orchestration-modules.

Required Configuration for Orchestration Modules

One configuration is consistently present in both modules that make up
the orchestration-modules. That is, the Terraform data source to the
Terraform backend for the Transit Gateway solution mentioned in earlier
segments of this document.

This backend configuration allows VPCs to automatically integrate with
an available transit gateway in the AWS Region where the VPC exist. This
transit gateway must have been deployed by the transit gateway solution
outlined in this document.
```
Note:
----------------------------------------------------------------------------
It is important to note that the Terraform backend used throughout this
solution is AWS S3.

Customers can bring their own backend by configuring the backend.tf file
to suite their own state storage requirements.

The backend.tf file is located in the root of the repository for all the
solutions mentioned in this document.

-----------------------------------------------------------------------------
```




####Shared Services VPC Orchestration-Module Backend Data Source Configuration

```hcl-terraform


/*
AWS Transit Gateway Terraform Module State | -------> Loaded from Amazon S3

This data source loads the terraform state file from the terraform
backend where it is stored. In this case the
backend used is Amazon S3. If you use a different backend then please
change the backend configuration
to match your backend.

If you don't have a back then please comment out this data source
block.

*/

data "terraform_remote_state" "transit_gateway_network" {
	backend = "s3"
	config = {
            # Please populate with the name of the S3 bucket that holds the terraform.tfstate file for your transit_gateway
            bucket = var.tf_backend_s3_bucket_name
            # Please populate with the key name the terraform.tfstate file for your transit_gateway
            key = var.tf_backend_state_file_s3_prefixpath_n_key_name
            # Please populate with the AWS Region for the S3 bucket that stores the terraform.tfstate file for your transit_gateway
            region = var.tf_backend_s3_bucket_aws_region
    }
}


```

The data source references three variables. That said, if you use AWS S3
as your backend then ensure that you add your backend configuration to
these variables.

The variables are as follows.

-   *tf_backend_s3_bucket_aws_region*

-   *tf_backend_state_file_s3_prefixpath_n\_key_name*

-   *tf_backend_s3_bucket_name*

If you do not use AWS S3 as your backend then you will be required to
add configuration that creates a data source to your backend.

Shared Service VPC Orchestration Module

***aws-financial-services-framework-deploy-shared-services-vpc***

The shared services orchestration module is pre-configured to create a
shared services VPC with centralized services that are distributed
throughout the entire network.

Customers can change these

Shared Service VPC Orchestration Module

***aws-financial-services-framework-deploy-shared-services-vpc***

To be added.

# **Network Deployer Deployment Guide** 

# **Network Deployment Options**

The network deployment solution provides customers with four deployment
types. Each deployment is predicated four use cases.

These use cases are as follows:

1.  **Stand-alone Spoke VPC**

    a.  Stand-alone VPC(s) deploys an AWS Virtual Private Cloud
        environment with:

        i.  AWS VPC Subnets

        ii. VPC Gateway & Interface Endpoints

        iii. VPC Flowlog

        iv. EC2 Security Groups of type:

            1.  Database

            2.  Web Application

            3.  Apache Spark

            4.  Elasticsearch

            5.  And more.

        v.  Private Hosted Zone (optional)

        vi. Route 53 Resolver Endpoints (inbound and outbound)

2.  **Stand-alone Shared Services VPC with centralized components**

    a.  The stand-alone shared services VPC option deploys a VPC with
        all the above components. It also deploys a centralized VPC
        Interface Endpoints solution.

> That is, it deploys the VPC Interface Endpoints that you enable. These
> endpoints have private DNS disabled and an AWS Route 53 Private Hosted
> Zone for each service that you have an endpoint for.
>
> It's important to note that if you deploy the stand-alone shared
> services VPC then you must build your own logic that allows your spoke
> VPCs to discover and associate with the available AWS Route 53 Private
> Hosted Zones.
>
> If you deploy the fully integrated network solution then each spoke
> VPC automatically discover and associate itself with the private
> hosted zones that front-ends each endpoint.

3.  **Integrated Spoke VPC and Shared Services VPC with automated
    association with centralized DNS and centralized VPC Interface
    Endpoint resources.**

    a.  In this option, the spoke VPC deployed with a configurations
        that enable the automatic discovery and association with
        centralized resources inside the shared services VPC.

4.  **Integrated Spoke VPC and Shared Services VPC with automated
    association with centralized DNS and centralized VPC Interface
    Endpoint resources plus automated integration with the global AWS
    Transit Gateway Solution**

    a.  This option includes all the components stated above plus
        integration components that automates each spoke and shared
        services VPC to associate with the transit gateway that serves
        that region.

    b.  The transit gateway route table would be automatically
        configured based on tags attached to the VPC.

# **Deployment Option Implementation Guide**

# **Terraform Provider Prerequisites** 

One of the first decisions a customer makes before deploying an AWS VPC
is the AWS Region in which to deploy.

In this solution the *provider.tf* file has been purposefully configured
to make it easy for a customer to chose which AWS Region to deploy to.
Each AWS Region has been declared along with an alias.

In the *main.tf* file contains three modules. These are as follows:

1.  *pave_account_with_network_orchestration_components*

2.  *shared_services_vpc*

3.  *spoke_vpc*

Each module contains a provider declaration. An example is displayed
below.

```hcl-terraform

providers = {
    aws = aws.paris # Please look in the provider.tf file for all the pre-configured providers. Choose the one that matches your requirements.
}

```

Please peruse the *provider.tf* file look at the alias name that matches
the AWS Region where you would like to deploy.

Once you have identified the alias you want, open the *main.tf* file,
locate the module that matches the solution that you want to deploy.
Then use the alias to configure the provider snippet inside the module.

**Account Paving
Prerequisites**

Before you deploy any of the options mentioned above, you must ensure
your account is paved with AWS infrastructure that orchestrates the
creation of different networking features.

The network components deployed during the paving process are as
follows:

1.  **AWS EventBridge EventBus**

    a.  An event bus is created specifically for orchestrating
        networking tasks.

    b.  Six rules are also created and all rules trigger the Lambda
        function that handle the execution of network oriented tasks.

2.  **AWS Lambda Function: Performs Network Operations**

    a.  This function performs the heavy lifting of configuring
        centralized resources and associating spoke VPCs with these
        centralized resources.

    b.  The tasks performed by this function includes:

        i.  Configuring routing within the transit gateway based on the
            following criteria:

            1.  VPC Type (that is, dev, test, prod, shared service,
                packet inspection)

            2.  Traffic Inspection requirements

        ii. Associates the shared services VPC with AWS Route 53 Private
            Hosted Zones that were created in the spoke VPC

        iii. Creates resolver rules for the domain and sub-domain of the
             spoke private hosted zone(s)

        iv. Creates AWS Resource Access Manager (RAM) resource shares
            and share it with the root OU or entire AWS Organization
            tree for that customer.

        v.  Complete the spoke VPC association with all the private
            hosted zones that front end the interface endpoints.

3.  **AWS Lambda Function: Add Networking Events to Shared Service
    Account AWS EventBus**

    a.  This function triggers network operations by writing tasks that
        needs to be performed to the event bus in the shared services
        account or the account in which it is hosted.

Network Paving should occur before any VPC type is deployed. Paving
actions depends on the deployment option you want to implement.

The deployment option you choose impacts paving as follows:

1.  **Stand-alone Spoke VPC Deployment Option**

    a.  If you are deploying a stand-alone VPC then you don't need to
        perform any paving task

2.  **Paving must be done for each of the following deployment option**

    i.  Stand-alone Shared Services VPC with centralized components

    ii. Fully integrated Spoke VPC and Shared Services VPC with
        automated association with centralized DNS and centralized VPC
        Interface Endpoint resources

    iii. Integrated Spoke VPC and Shared Services VPC with automated
         association with centralized DNS and centralized VPC Interface
         Endpoint resources plus automated integration with the global
         AWS Transit Gateway Solution

Let's take a look at the paving tasks per deployment option

# **Account Paving Task Step by Step Guide**

Before deploying any of the [network deployment
options](#network-deployment-options), you must first ensure each
account is paved with the network orchestration components discussed in
[Account Paving Prerequisites](#_Account_Paving_Prerequisites) section
of this document.

Account paving deploys the orchestration infrastructure in the AWS
Region where you plan to deploy either a spoke VPC or shared services
VPC.

Here are the step by step actions to take to pave each region in the
account where the network is being deployed:

**Step 1.**

Configure the *backend.tf* file in the root of the repo/directory. It is
important that you are intentional about Terraform state storage.

I.  By default, this solution is built around storing state in AWS S3.

**Illustrated *backend.tf* file**

1.  ```hcl-terraform
    terraform{
        backend "s3"{
            # Please populate with the name of the S3 bucket that holds the terraform.tfstate file for your transit_gateway
            bucket = "EXAMPLE-aws-fsf-team-terraform-state-storage" # aws S3 bucket
            # Please populate with the key name the terraform.tfstate file for your transit_gateway
            key = "EXAMPLE-aws-fsf-terraform-network-state/spoke/account-number/PLEASE-ADD-YOUR-ACCOUNT-NUMBER-HERE/vpc/terraform.tfstate"
            # S3 key
            # Please populate with the AWS Region for the S3 bucket that stores the terraform.tfstate file for your transit_gateway
            region = "EXAMPLE-us-east-2" # aws region where your S3 bucket is located
        }
    }
    ```

> Ensure the backend.tf file is configured and points to where you
> intend to store the state data for this paving process or all paving
> processes.
>
> Please note that paving state should be stored separately from VPC
> deployment state.
>
> The paving state data is made available to each VPC deployment through
> Terraforms data backend sources configuration.

**Step 2.**

Open the variables.tf file in the root of the repo/directory. Locate the
variable "*which_vpc_type_are_you_creating*" and ensure the variable is
configured as shown below:

```hcl-terraform
variable "which_vpc_type_are_you_creating" {
    type = map(bool)
    default = {
        shared_services_vpc     = false # Specify true or false
        spoke_vpc               = false # Specify true or false
        pave_account_with_eventbus_n_lambda_fn_for_network_task_orchestration  = true # Specify true or false
    }
}
```

**Step 3.**

Open the main.tf file and locate the module reference labeled
"*pave_account_with_network_orchestration_components*" and ensure that
the provider being used is the provider you need. To see a list of all
the providers please open the *provider.tf* file. The provider name
corresponds with the region where the infrastructure is being deployed.

**Step 4.**

Once these are all configured as recommended then you can trigger a
*terraform init*, then *terraform apply.*

# **Deployment Options & Account Paving** 

1.  **Stand-alone Shared Services VPC with Centralized Components**

    a.  Please complete all steps outlined in [Account Paving Task Step
        by Step Guide](#account-paving-task-step-by-step-guide). Given
        that this is a stand-alone deployment with no integration with a
        transit gateway or spoke VPC, you wont need to perform any other
        step.

    b.  The IAM Role that performs the deployment of the stand-alone
        shared services VPC should be able to access the AWS S3 bucket
        where the state data for the paved components is stored.

    c.  Please note that you can bring your own backend. You are not
        tied to AWS S3 for storing terraform state data.

2.  **Integrated Spoke VPC and Shared Services VPC with automated
    association with centralized DNS and centralized VPC Interface
    Endpoint resources.**

    a.  In order for there to be integration between the spoke and
        shared services VPC there must be awareness of both
        environments. That is, the account in which the spoke VPC is
        being deployed must be aware of the AWS EventBus inside the
        shared services account. In return, the shared services account
        must be aware of the spoke account AWS EventBus.

> Awareness of the shared services AWS EventBus allows the spoke VPC
> deployment process to write association events to shared services
> event bus. The shared services account triggers the network operations
> lambda to perform the network task outlined in the event. For some
> tasks, the lambda function writes a status update to the spoke account
> event bus in the same AWS Region.
>
> The event that is written by the spoke VPC deployment process to the
> shared services AWS EventBus sometimes includes the AWS EventBus ARN
> that supports network operations for the spoke VPC in a specific AWS
> Region.
>
> The spoke account achieves awareness of the shared services AWS
> EventBus via a *terraform_remote_state* data source that is declared
> and used by the spoke module for importing the state data for the
> shared services pavement task.
>
> In the [orchestration-module](#orchestration-modules-deep) that
> supports the deployment of the spoke VPC there are four
> *terraform_remote_state* data source. The data source receive their
> configuration values from several values in the variables.tf file that
> is located in the root directory of the solution repo/directory.
>
> The name of these *terraform_remote_state* data source are as follows:

1.  *shared_services_network_paving_components*

2.  *shared_services_network*

3.  *transit_gateway_network*

4.  *this_account_network_paving_components*

> As you can see there two *terraform_remote_state* data source to
> account pavement state data.
>
> One for the shared services account and another for the spoke account.
> It is therefore important to ensure the follow configuration takes
> place and in the order provided.
>
> **Step 1.**
>
> Ensure that the shared services account is paved. Follow the
> instructions outlined in [Account Paving Task Step by Step
> Guide](#account-paving-task-step-by-step-guide) to achieve this
> outcome. Shared services account and spoke account are different. It
> is therefore, important that the spoke account IAM Role for deploying
> the spoke networks have access to the Terraform backend where state
> for the Shared services account is stored.
>
> **Step 2.**
>
> Once the paving of the shared services account is completed and the
> shared services VPC has been deployed then proceed with paving the
> spoke account(s) with the necessary network orchestration
> infrastructure that is required for integrating the spoke VPC with
> shared resources in the shared services account. The spoke VPC can be
> deployed once pavement is done.

Once the pavement tasks are all completed successfully you can proceed
to deploying the VPCs.

The steps to deploy these VPCs are outlined in the following section.

# **Deployment Options & How to Deploy Them** 

Now that the [Account Paving
Prerequisites](#_Account_Paving_Prerequisites) tasks are completed. You
can now move forward with deploying your networks on AWS.

Let's take a look at each deployment option and how to tune the
Terraform modules in order to deploy each deployment type.

Once again, network deployment and account paving deployments should be
stored in different state file.

Now that that's out of the way let's dive into each deployment option
and how to deploy them.

### **Deploying a Stand-alone Spoke VPC**

**Step 1.**

In the root of the solution directory, open your *backend.tf* file and
configure your Terraform backend. You can bring your own backend if S3
is not your backend TF state.

It is important to note that for stand-alone VPCs the state data can be
local to the account as there is no need for this state to be shared
with any other account via a terraform remote state data source.

```hcl-terraform

terraform{
    backend "s3"{
        # Please populate with the name of the S3 bucket that holds the terraform.tfstate file for your transit_gateway
        bucket = "EXAMPLE-aws-fsf-team-terraform-state-storage" # aws S3 bucket
        # Please populate with the key name the terraform.tfstate file for your transit_gateway
        key = "EXAMPLE-aws-fsf-terraform-network-state/spoke/account-number/PLEASE-ADD-YOUR-ACCOUNT-NUMBER-HERE/vpc/terraform.tfstate"
        # S3 key
        # Please populate with the AWS Region for the S3 bucket that stores the erraform.tfstate file for your transit_gateway
        region = "EXAMPLE-us-east-2" # aws region where your S3 bucket is located
    }
}

```
**Step 2.**

The next step is to configure several variables in the *variables.tf*
file. That said, in the root of the solution directory, open your
*variables.tf* file and perform the following configurations as
illustrated below.

A.  Configuration the variable *which_vpc_type_are_you_creating* as
    shown below. This tells the solution that you would like to create a
    spoke VPC.

```hcl-terraform

variable "which_vpc_type_are_you_creating" {
    type = map(bool)
    default = {
        shared_services_vpc         = false                                             # Specify true or false
        spoke_vpc                   = true                                              # Specify true or false
        pave_account_with_eventbus_n_lambda_fn_for_network_task_orchestration = false   # Specify true or false
    }
}

```

B.  Now that you have told the solution the type of VPC you want, let's
    disable all other features so that the VPC deployed is stand-alone.

> First, disable all features in the variable
> *transit_gateway_association_instructions* as shown below.

```hcl-terraform
variable "transit_gateway_association_instructions" {
    type = map(bool)
    default = {
        create_transit_gateway_association                          = false # Specify true or false | Associates VPC with AWS Transit Gateway
        access_shared_services_vpc                                  = false # Specify true or false | Propagates VPC routes to Shared Services Route Table
        perform_east_west_packet_inspection                         = false # Specify true or false | Propagates VPC routes to Packet Inspection Route Table for North-South Packet Inspection
        allow_onprem_access_to_entire_vpc_cidr_range                = false # Specify true or false | Propagate Routes to On-premises Route Table
        allow_onprem_access_to_externally_routable_vpc_cidr_range   = false # Specify true or false | Propagate Routes to On-premises Route Table
    
    }
}

```
C.  Configure the variable *security_grp_traffic_pattern*. This variable
    tells the solution which pre-configured AWS EC2 Security Group to
    create. Base on the below configuration, this solution will create a
    database security group and a security for web services (by default
    HTTPS is the only protocol allowed in the web services security
    group).

> Please feel free to disable these enabled ones if they are not needed.
>
```hcl-terraform
  

  variable "security_grp_traffic_pattern" {
       type = map(bool)
       default = {
           database         = true      # Specify true or false
           web              = true      # Specify true or false
           kafka_zookeeper  = false     # Specify true or false
           elasticsearch    = false     # Specify true or false
           apache_spark     = false     # Specify true or false
       }
   }
  
  
  
  ```
>
> The security group module also uses the variable *on_premises_cidrs*
> for specifying which IP ranges are allowed to send inbound traffic to
> your VPC.
>
> VPCs are locked down by default. The only external IP ranges that will
> be able to access your VPC are those you add to the
> *on_premises_cidrs* variable list.
>
> Please see an example of this list below. Replace the IP range example
> with your IP ranges.
>
```hcl-terraform
  

  variable "on_premises_cidrs" {
       description = "On-premises or non VPC network range"
       type = list(string)
       default = [ "172.16.0.0/16", "172.17.0.0/16", "172.18.0.0/16", "172.19.0.0/16", "172.20.0.0/16", "172.22.0.0/16" ]
   }
  
  
  ```

D.  As stated in other sections of this document, this solution creates
    several types of AWS VPC Endpoints. In this step you are required to
    enable the VPC endpoints of your choice.

> By default, AWS S3 and DynamoDB are enabled. Please feel free to
> enable others if you require it.
>
> If you are interested in using AWS Systems Manager Sessions Manager
> for remote access then you will need to enable the endpoints for EC2,
> EC2 Messages, SSM and SSM Messages.

```hcl-terraform

variable "endpoints" {
    type = map(bool)
    default = {
        s3_gateway          = true      # Specify true or false
        dynamodb            = true      # Specify true or false
        secrets_manager     = false     # Specify true or false
        kms                 = false     # Specify true or false
        ec2                 = false     # Specify true or false
        ec2_messages        = false     # Specify true or false
        ecs                 = false     # Specify true or false
        ecs_agent           = false     # Specify true or false
        ecs_telemetry       = false     # Specify true or false
        sts                 = false     # Specify true or false
        sns                 = false     # Specify true or false
        sqs                 = false     # Specify true or false
        ssm                 = false     # Specify true or false
        ssm_messages        = false     # Specify true or false
    }
}

```

E.  Next, you will need to configure the variable *route53_acts*. This
    variable allow customers to enable DNS features for the VPC being
    deploy.

> That said, the only feature you can enable for a stand-alone VPC is an
> AWS Route 53 Private Hosted Zone (PHZ).
>
> If you need a PHZ for this VPC, then configure the variable as shown
> below. If not, then change *true* to false for the variable option
> *create_standalone_private_hosted_zone.*

```hcl-terraform

variable "route53_acts" {
    type = map(bool)
    default = {
        create_standalone_private_hosted_zone                                       = true      # Specify true or false
        create_private_hosted_zone_that_integrates_with_shared_services_or_dns_vpc  = false     # Specify true or false
        associate_with_dns_vpc_or_a_shared_services_vpc                             = false     # Specify true or false
        associate_with_private_hosted_zone_with_centralized_dns_solution            = false     # Specify true or false
        create_forwarding_rule_for_sub_domain                                       = false     # Specify true or false
        create_forwarding_rule_for_domain                                           = false     # Specify true or false
        share_forwarding_rule_with_aws_organization                                 = false     # Specify true or false
    }
}


```
F.  Now, given that this is a stand-alone VPC there is no need to attach
    it to any centrally shared resources like VPC endpoints.

> That said, disable all the features in the variable
> *is_centralize_interface_endpoints_available* as shown below.

```hcl-terraform

variable "is_centralize_interface_endpoints_available" {
    type = map(bool)
    default = {
        is_centralized_interface_endpoints      = false     # Specify true or false
        associate_with_private_hosted_zones     = false     # Specify true or false
    }
}

```
G.  The final variables.tf file configuration is the configuration of
    the variable *attach_to_centralize_dns_solution* as shown below.

```hcl-terraform
variable "attach_to_centralize_dns_solution"{
	default = false # Specify true or false
}
```

**Step 3.**

Now that the *variables.tf* file is complete, it is time to configure
the *main.tf* file. The *main.tf* file contains three module references.

These modules are as follows:

4.  *pave_account_with_network_orchestration_components*

5.  *shared_services_vpc*

6.  *spoke_vpc*

The module of interest for the deployment of a stand-alone spoke VPC is
the *spoke_vpc* module.

The configurations that are required are as follows:

A.  Add a CIDR range for your VPC. There is a default CIDR of
    100.65.0.0/16

``` 
vpc_cidr_block = "100.65.0.0/16" 
```

B.  Add subnets to be used as public subnets. You must add at least two
    subnets to the list. If you add less than two then terraform will
    throw an error. This solution is built to create resources according
    to AWS best practices.

```
 public_subnets = ["100.65.1.0/24", "100.65.2.0/24", "100.65.3.0/24"] 
```

C.  Add your private subnets. Again add at least two subnets to the
    list.

``` 
private_subnets = ["100.65.4.0/24\", "100.65.5.0/24", "100.65.6.0/24"]
```

D.  Add at least two /28 subnets to be used in the future to host your
    transit gateway attachment network interfaces.

``` 
transit_gateway_subnets = ["100.65.7.0/28", "100.65.8.0/28", "100.65.9.0/28"]
```

E.  Lastly, if you enabled *create_standalone_private_hosted_zone* in
    the variable *route53_acts* then you need to add at least one hosted
    zone to the *private_hosted_zone_name*

``` 
private_hosted_zone_name = ["anaconda.aws-fsf-corp.com"]
```

### **Deploying a Stand-alone Shared Services VPC with Centralized Resources**

**Step 1.**

In the root of the solution directory, open your *backend.tf* file and
configure your Terraform backend. You can bring your own backend if S3
is not your backend TF state.

It is important to note that for stand-alone shared services VPCs the
state data can be local to the account as there is no need for this
state to be shared with any other account via a terraform remote state
data source.

However, if you wish to share this state then you have to ensure that
the entities you plan on sharing with has access to the state
repository.

```hcl-terraform

terraform{
    backend "s3"{
        # Please populate with the name of the S3 bucket that holds the terraform.tfstate file for your transit_gateway
        bucket = "EXAMPLE-aws-fsf-team-terraform-state-storage" # aws S3 bucket
        # Please populate with the key name the terraform.tfstate file for your transit_gateway
        key = "EXAMPLE-aws-fsf-terraform-network-state/spoke/account-number/PLEASE-ADD-YOUR-ACCOUNT-NUMBER-HERE/vpc/terraform.tfstate"
        # S3 key
        # Please populate with the AWS Region for the S3 bucket that stores the terraform.tfstate file for your transit_gateway
        region = "EXAMPLE-us-east-2" # aws region where your S3 bucket is located
    }
}

```

**Step 2.**

The next step is to configure several variables in the *variables.tf*
file. That said, in the root of the solution directory, open your
*variables.tf* file and perform the following configurations as
illustrated below.

A.  Configuration the variable *which_vpc_type_are_you_creating* as
    shown below. This tells the solution that you would like to create a
    spoke VPC.

```hcl-terraform

variable "which_vpc_type_are_you_creating" {
    type = map(bool)
    default = {
        shared_services_vpc     = true # Specify true or false
        spoke_vpc               = false # Specify true or false
        pave_account_with_eventbus_n_lambda_fn_for_network_task_orchestration = false # Specify true or false
    }
}

```

B.  Now that you have told the solution the type of VPC you want, let's
    disable all other features so that the VPC deployed is stand-alone.

> First, disable all features in the variable
> *transit_gateway_association_instructions* as shown below.

```hcl-terraform

variable "transit_gateway_association_instructions" {
    type = map(bool)
    default = {
        create_transit_gateway_association                          = false # Specify true or false | Associates VPC with AWS Transit Gateway
        access_shared_services_vpc                                  = false # Specify true or false | Propagates VPC routes to Shared Services Route Table
        perform_east_west_packet_inspection                         = false # Specify true or false | Propagates VPC routes to Packet Inspection Route Table for North-South Packet Inspection
        allow_onprem_access_to_entire_vpc_cidr_range                = false # Specify true or false | Propagate Routes to On-premises Route Table
        allow_onprem_access_to_externally_routable_vpc_cidr_range   = false # Specify true or false | Propagate Routes to On-premises Route Table
    
    }
}

```

C.  Configure the variable *security_grp_traffic_pattern*. This variable
    tells the solution which pre-configured AWS EC2 Security Group to
    create. Base on the below configuration, this solution will create a
    database security group and a security for web services (by default
    HTTPS is the only protocol allowed in the web services security
    group).

> Please feel free to disable these enabled ones if they are not needed.
>
```hcl-terraform
 variable "security_grp_traffic_pattern" {
     type = map(bool)
     default = {
         database           = true  # Specify true or false
         web                = true  # Specify true or false
         kafka_zookeeper    = false # Specify true or false
         elasticsearch      = false # Specify true or false
         apache_spark       = false # Specify true or false
     }
 }

```
>
> The security group module also uses the variable *on_premises_cidrs*
> for specifying which IP ranges are allowed to send inbound traffic to
> your VPC.
>
> VPCs are locked down by default. The only external IP ranges that will
> be able to access your VPC are those you add to the
> *on_premises_cidrs* variable list.
>
> Please see an example of this list below. Replace the IP range example
> with your IP ranges.
>
```hcl-terraform
variable "on_premises_cidrs" {
 description = "On-premises or non VPC network range"
 type = list(string)
 default = [ "172.16.0.0/16", "172.17.0.0/16", "172.18.0.0/16", "172.19.0.0/16", "172.20.0.0/16", "172.22.0.0/16" ]
}
```

**Step 3.**

The stand-alone shared services VPC reference module has minimal
configuration requirements. This is because majority of the
orchestration and deployment configuration lives inside orchestration
module, *aws-financial-services-framework-deploy-shared-services-vpc.*

That said, now that the *variables.tf* file configuration is complete,
it is time to configure the *main.tf* file.

The *main.tf* file contains three module references. These modules are
as follows:

7.  *pave_account_with_network_orchestration_components*

8.  *shared_services_vpc*

9.  *spoke_vpc*

The module of interest for the deployment of a stand-alone shared
services VPC is the *shared_services_vpc* module.

The configurations that are required are as follows:

F.  Add a CIDR range for your VPC. There is a default CIDR of
    100.64.0.0/16

```
vpc_cidr_block = "100.64.0.0/16"
```

G.  Add subnets to be used as public subnets. You must add at least two
    subnets to the list. If you add less than two then terraform will
    throw an error. This solution is built to create resources according
    to AWS best practices.

```
public_subnets = ["100.64.1.0/24", "100.64.2.0/24", "100.65.3.0/24"]
```

H.  Add your private subnets. Again add at least two subnets to the
    list.

```
private_subnets = ["100.64.4.0/24", "100.64.5.0/24", "100.64.6.0/24"]
```

I.  Add at least two /28 subnets to be used in the future to host your
    transit gateway attachment network interfaces.

``` 
 transit_gateway_subnets = ["100.64.7.0/28”, "100.64.8.0/28", "100.64.9.0/28”]
 ```

### **Deploying the Integrated Spoke VPC and Shared Services VPC with automated association with centralized DNS and centralized VPC Interface Endpoint resources**

This deployment option builds a hub and spoke network in which the
shared service VPC makes available all of the centralized resources that
it hosts. Spoke VPCs are built to auto discover these resources and
associate with them.

Automated AWS Transit Gateway discovery and association is not a feature
of this deployment option. If you deploy this option, it is assumed that
you already have a transitive network and the VPCs being deployed here
are being deployed to fit into that network.

If you wish to deploy the deployment option that allows each shared
services VPC and spoke VPC to auto discover, associate and trigger the
their custom transit gateway route table configuration then you need to
deploy the *Integrated Spoke VPC and Shared Services VPC with automated
association with centralized DNS and centralized VPC Interface Endpoint
resources plus automated integration with the global AWS Transit Gateway
Solution*.

For more details on the global AWS Transit Gateway solution, please see
the [transit gateway solution outlined earlier in this
document.](#the-aws-transit-gateway-repository-and-modules)

Now, let's dive into the configuration instructions.

**Step 1: Deploy the Shared Service VPC**

Before deploying the shared services VPC, please ensure that you
complete the pre-requisites outlined in the [Account Paving Task Step by
Step Guide](#account-paving-task-step-by-step-guide).

Once the shared services account is paved, make a note of the backend
details you used for the *backend.tf* file that was used to deploy the
paving services inside the shared services account.

Now, lets dive in to the steps to deploy the shared services account.

A.  First, configure the *backend.tf* file for the deployment of the
    shared services account. Once again, it is recommended that paving
    state be stored differently from VPC state.

B.  Once your *backend.tf* is configured, open the *variables.tf* file
    and configure the variable *which_vpc_type_are_you_creating* as
    illustrated below.
    
```hcl-terraform


 variable "which_vpc_type_are_you_creating" {
     type = map(bool)
     default = {
         shared_services_vpc    = true      # Specify true or false
         spoke_vpc              = false     # Specify true or false
         pave_account_with_eventbus_n_lambda_fn_for_network_task_orchestration = false # Specify true or false
     }
 }


```
C.  Next, use the same parameters you used to configure your backend.tf
    file and configure the below variables appropriately. These
    variables are located in the *variables.tf*.
```hcl-terraform


# ------------------------------------------------------------------------
# SHARED SERVICES VPC | Backend Configuration for use with TerraformBackend Data Source
# ------------------------------------------------------------------------
# This Terraform Backend is configured for Amazon S3 by default; 
# however, you can replace this default config and replace it with yours.
# ------------------------------------------------------------------------
 
variable "tf_shared_services_backend_s3_bucket_aws_region"{
     default = "us-east-2"
     # Please fill in the aws S3 region where the bucket is being hosted
 }
 
 variable "tf_shared_services_backend_s3_bucket_name"{
     default = "aws-fsf-team-terraform-state-storage"
     # Please fill in the aws S3 bucket name that you are using to store terraform state for your shared services
 }
 
 variable “tf_shared_services_backend_state_file_s3_prefixpath_n_key_name" {
     default = "aws-fsf-terraform-network-state/shared-services-vpc/account-number/PLEASE-ADD-YOUR-ACCOUNT-NUMBER-HERE/vpc/terraform.tfstate"
     # The S3 key or prefix+key for the terraform state file
 }

```
D.  Once done, use the parameters you used to configure the *backend.tf*
    for your shares services account paving deployment to fill out the
    below variables. These variables are also found in the *variable.tf*
    file.

```hcl-terraform

#------------------------------------------------------------------------------
# SHARED SERVICES | NETWORK PAVING COMPONENTS TERRAFORM BACKEND | - Configuration Parameters
#------------------------------------------------------------------------------
variable "tf_shared_services_network_paving_components_backend_s3_bucket_aws_region"{
    default = "EXAMPLE-us-east-2" # "PLEASE ADD THE AWS-REGION-CODE WHERE YOUR BUCKET WITH THIS STATE DATA EXIST"
}

variable "tf_shared_services_network_paving_components_backend_s3_bucket_name"{
    default = "EXAMPLE-aws-fsf-team-terraform-state-storage" # “PLEASE ADD YOUR-AWS-S3-BUCKET-NAME WHERE YOUR STATE DATA IS STORED"
}

variable "tf_shared_services_network_paving_components_backend_state_file_s3_prefixpath_n_key_name" { # "PLEASE ADD YOUR-S3-PREFIX-PATH+KEY-FOR-THIS-ACCOUNT-NETWORK-PAVING-COMPONENTS-VPC-STATE-FILE IS STORED"
default = "EXAMPLE-aws-fsf-terraform-network-state/shared-services-vpc/account-number/PLEASE-ADD-YOUR-ACCOUNT-NUMBER-HERE/terraform.tfstate"
}

```

E.  Given that you already have a layer three hub that was not deployed
    by the [transit gateway solution outlined earlier in this
    document.](#the-aws-transit-gateway-repository-and-modules) Lets go
    ahead and ensure that integration point to that transit gateway
    solution are disabled.

> In the *variables.tf* file locate the variable
> "*transit_gateway_association_instructions*" and ensure it is
> configured as shown below.
>
```hcl-terraform


variable "transit_gateway_association_instructions" {
    type = map(bool)
    default = {
        create_transit_gateway_association                          = false # Specify true or false | Associates VPC with AWS Transit Gateway
        access_shared_services_vpc                                  = false # Specify true or false | Propagates VPC routes to Shared Services Route Table
        perform_east_west_packet_inspection                         = false # Specify true or false | Propagates VPC routes to Packet Inspection Route Table for North-South Packet Inspection
        allow_onprem_access_to_entire_vpc_cidr_range                = false # Specify true or false | Propagate Routes to On-premises Route Table
        allow_onprem_access_to_externally_routable_vpc_cidr_range   = false # Specify true or false | Propagate Routes to On-premises Route Table
}
}

```

F.  Finally, configure the variable *security_grp_traffic_pattern*. This
    variable tells the solution which pre-configured AWS EC2 Security
    Group to create. Base on the below configuration, this solution will
    create a database security group and a security for web services (by
    default HTTPS is the only protocol allowed in the web services
    security group).

> Please feel free to disable these enabled ones if they are not needed.
>
```hcl-terraform

variable "security_grp_traffic_pattern" {
     type = map(bool)
     default = {
         database           = true      # Specify true or false
         web                = true      # Specify true or false
         kafka_zookeeper    = false     # Specify true or false
         elasticsearch      = false     # Specify true or false
         apache_spark       = false     # Specify true or false
     }
 }

```
>
> The security group module also uses the variable *on_premises_cidrs*
> for specifying which IP ranges are allowed to send inbound traffic to
> your VPC.
>
> VPCs are locked down by default. The only external IP ranges that will
> be able to access your VPC are those you add to the
> *on_premises_cidrs* variable list.
>
> Please see an example of this list below. Replace the IP range example
> with your IP ranges.

G.  At this point, configurations for the *variable.tf* file should be
    completed. Let's turn our gaze to the *main.tf* file and work
    through the final set of configurations.

> Open the *main.tf* file and go to the *shared services VPC* module.

i.  Ensure the provider that's specified is correct.

ii. Add a CIDR range for your VPC. There is a default CIDR of
    100.64.0.0/16

```
vpc_cidr_block = "100.64.0.0/16"
```

iii. Add subnets to be used as public subnets. You must add at least two
     subnets to the list. If you add less than two then terraform will
     throw an error. This solution is built to create resources
     according to AWS best practices.

``` 
 public_subnets = ["100.64.1.0/24", "100.64.2.0/24”, "100.65.3.0/24"]
```

iv. Add your private subnets. Again add at least two subnets to the
    list.

``` 
private_subnets = ["100.64.4.0/24", "100.64.5.0/24", "100.64.6.0/24"]
```

v.  Add at least two /28 subnets to be used in the future to host your
    transit gateway attachment network interfaces.

``` 
transit_gateway_subnets = ["100.64.7.0/28", "100.64.8.0/28", "100.64.9.0/28"]
```

That's concludes the shared service VPC configuration. Please feel free
to deploy this VPC by first running *terraform init* and then *terraform
apply*.

Once your shared services VPC is deployed it's time to deploy your spoke
VPC(s).

**Step 2: Deploying the Spoke VPC**

First step in deploying the spoke VPC as with any of the other solutions
is to configure the *backend.tf* file.

That said, go to the root of the solution directory and open your
*backend.tf* file and add your backend configuration.

S3 is the default backend that's used by this solution. An illustrated
example of the backend.tf file configuration is shown below.

```hcl-terraform
terraform{
    backend "s3"{
        # Please populate with the name of the S3 bucket that holds the terraform.tfstate file for your transit_gateway
        bucket = "EXAMPLE-aws-fsf-team-terraform-state-storage" # aws S3 bucket
        # Please populate with the key name the terraform.tfstate file for your transit_gateway
        key = "EXAMPLE-aws-fsf-terraform-network-state/spoke/account-number/PLEASE-ADD-YOUR-ACCOUNT-NUMBER-HERE/vpc/terraform.tfstate"
        # S3 key
        # Please populate with the AWS Region for the S3 bucket that stores the terraform.tfstate file for your transit_gateway
        region = "EXAMPLE-us-east-2" # aws region where your S3 bucket is located
    }
}

```

The next step is to configure several variables in the *variables.tf*
file located in the root of the solution directory. Open your
*variables.tf* file and perform the following configurations as
illustrated below.

A.  Configure the variable *which_vpc_type_are_you_creating* as shown
    below.

```hcl-terraform
variable "which_vpc_type_are_you_creating" {
    type = map(bool)
    default = {
        shared_services_vpc         = false # Specify true or false
        spoke_vpc                   = true # Specify true or false
        pave_account_with_eventbus_n_lambda_fn_for_network_task_orchestration = false # Specify true or false
    }
}

```

B.  Given that this spoke VPC is being deployed to automatically
    discover and associate with centrally distributed services inside
    the shared services account it must be aware of the shared services
    VPC and event bus (which acts as a point of entry for the shared
    services account.)

> This awareness is gained through the configuration of three sets of
> variables. To configure these variables you will need the details that
> were used to configure the backend.tf files for the shared services
> paving deployment and shared services VPC deployment.
>
> Once you have this information, please configure the below variables
> in order.
>
> **First,**
```hcl-terraform


#------------------------------------------------------------------------------
# SHARED SERVICES VPC | Backend Configuration for use with Terraform Backend Data Source
#------------------------------------------------------------------------------
# This Terraform Backend is configured for Amazon S3 by default; 
# however, you can replace this default config and replace it with yours.
#------------------------------------------------------------------------------

variable "tf_shared_services_backend_s3_bucket_aws_region"{
default = "PLEASE-ADD-AWS-REGION (example us-east-2)" # Please fill in the aws S3 region where the bucket is being hosted
}

variable "tf_shared_services_backend_s3_bucket_name"{
default = "PLEASE-ADD-AWS-BUCKET-NAME" # Please fill in the aws S3 bucket name that you are using to store terraform state for your shared services
}

variable "tf_shared_services_backend_state_file_s3_prefixpath_n_key_name"{
default = "PLEASE-ADD-S3-PREFIX-PATH/KEY-NAME" # The S3 key or prefix+key for the terraform state file
}

```

> **Secondly,**

```hcl-terraform 

#------------------------------------------------------------------------------
# SHARED SERVICES | NETWORK PAVING COMPONENTS TERRAFORM BACKEND | ->
Configuration Parameters
#------------------------------------------------------------------------------

variable "tf_shared_services_network_paving_components_backend_s3_bucket_aws_region"{
    default = "PLEASE-ADD-AWS-REGION (example us-east-2)" # "PLEASE ADD THE AWS-REGION-CODE WHERE YOUR BUCKET WITH THIS STATE DATA EXIST"
}


variable "tf_shared_services_network_paving_components_backend_s3_bucket_name"{
    default = "PLEASE-ADD-AWS-BUCKET-NAME" # "PLEASE ADD YOUR-AWS-S3-BUCKET-NAME WHERE YOUR STATE DATA IS STORED"
}


variable "tf_shared_services_network_paving_components_backend_state_file_s3_prefixpath_n_key_name"{
    default = "PLEASE-ADD-S3-PREFIX-PATH/KEY-NAME" # "PLEASE ADD YOUR-S3-PREFIX-PATH+KEY-FOR-THIS-ACCOUNT-NETWORK-PAVING-COMPONENTS-VPC-STATE-FILE\IS STORED"
}

```
> Lastly, you will need to configure the below variables using the
> details you used to configure the backend.tf file for paving this
> spoke account for the AWS Region where the spoke VPC is being
> deployed.
>
> The variables are listed below.

```hcl-terraform
#------------------------------------------------------------------------------
# THIS ACCOUNT | NETWORK PAVING COMPONENTS TERRAFORM BACKEND | -> Configuration Parameters
#———————————————————————————————————————
variable "tf_this_account_network_paving_components_backend_s3_bucket_aws_region"{
    default = "PLEASE-ADD-AWS-REGION (example us-east-2)" # "PLEASE ADD THE AWS-REGION-CODE WHERE YOUR BUCKET WITH THIS STATE DATA EXIST"
}

variable "tf_this_account_network_paving_components_backend_s3_bucket_name"{
    default = "PLEASE-ADD-AWS-BUCKET-NAME" # "PLEASE ADD YOUR-AWS-S3-BUCKET-NAME WHERE YOUR STATE DATA IS STORED"
}

variable "tf_this_account_network_paving_components_backend_state_file_s3_prefixpath_n_key_name"{
    default = "PLEASE-ADD-S3-PREFIX-PATH/KEY-NAME" # "PLEASE ADD YOUR-S3-PREFIX-PATH+KEY-FOR-THIS-ACCOUNT-NETWORK-PAVING-COMPONENTS-VPC-STATE-FILE IS STORED”
}

```
C.  Next disable all features in the variable
    *transit_gateway_association_instructions* as shown below.

```hcl-terraform
variable "transit_gateway_association_instructions" {
    type = map(bool)
    default = {
        create_transit_gateway_association                          = false # Specify true or false | Associates VPC with AWS Transit Gateway
        access_shared_services_vpc                                  = false # Specify true or false | Propagates VPC routes to Shared Services Route Table
        perform_east_west_packet_inspection                         = false # Specify true or false | Propagates VPC routes to Packet Inspection Route Table for North-South Packet Inspection
        allow_onprem_access_to_entire_vpc_cidr_range                = false # Specify true or false | Propagate Routes to On-premises Route Table
        allow_onprem_access_to_externally_routable_vpc_cidr_range   = false # Specify true or false | Propagate Routes to On-premises Route Table
    
    }
}

```

D.  Configure the variable *security_grp_traffic_pattern*. This variable
    tells the solution which pre-configured AWS EC2 Security Group to
    create. Base on the below configuration, this solution will create a
    database security group and a security for web services (by default
    HTTPS is the only protocol allowed in the web services security
    group).

> Please feel free to configure this variable as needed.
>
```hcl-terraform
 variable "security_grp_traffic_pattern" {
     type = map(bool)
     default = {
         database           = true      # Specify true or false
         web                = true      # Specify true or false
         kafka_zookeeper    = false     # Specify true or false
         elasticsearch      = false     # Specify true or false
         apache_spark       = false     # Specify true or false
     }
 }
```
>
> The security group module also uses the variable *on_premises_cidrs*
> for specifying which IP ranges are allowed to send inbound traffic to
> your VPC.
>
> VPCs are locked down by default. The only external IP ranges that will
> be able to access your VPC are those you add to the
> *on_premises_cidrs* variable list.
>
> Please see an example of this list below. Replace the IP range example
> with your IP ranges.
>
```hcl-terraform
variable "on_premises_cidrs" {
     description = "On-premises or non VPC network range"
     type = list(string)
     default = [ "172.16.0.0/16", "172.17.0.0/16", "172.18.0.0/16", "172.19.0.0/16", "172.20.0.0/16", "172.22.0.0/16" ]
}
```

E.  Next, configure the variable endpoints. Ensure that only the
    endpoints for S3 and DynamoDB are enabled.

> This spoke VPC will auto discover all interface endpoints that are
> centrally being shared from the shared services account for this
> specific AWS Region. Please ensure you configure this variable as seen
> below.

```hcl-terraform

variable "endpoints" {
    type = map(bool)
    default = {
        s3_gateway          = true      # Specify true or false
        dynamodb            = true      # Specify true or false
        secrets_manager     = false     # Specify true or false
        kms                 = false     # Specify true or false
        ec2                 = false     # Specify true or false
        ec2_messages        = false     # Specify true or false
        ecs                 = false     # Specify true or false
        ecs_agent           = false     # Specify true or false
        ecs_telemetry       = false     # Specify true or false
        sts                 = false     # Specify true or false
        sns                 = false     # Specify true or false
        sqs                 = false     # Specify true or false
        ssm                 = false     # Specify true or false
        ssm_messages        = false     # Specify true or false
    }
}

```

F.  Next, you will need to configure the variable *route53_acts*. This
    boolean variable map allows customers to enable the creation of an
    AWS Route 53 Private Hosted Zone for a VPC. It also allows customers
    enable the addition of this private hosted zone to a centralized DNS
    solution that is hosted inside the DNS/shared services account.

> If you would like to enable the creation of an AWS Private Hosted Zone
> for this VPC that is then attached to the centralized DNS solution
> inside the shared services account then please configure this variable
> as shown below.

```hcl-terraform
variable "route53_acts" {
    type = map(bool)
    default = {
        create_standalone_private_hosted_zone                                       = false # Specify true or false
        create_private_hosted_zone_that_integrates_with_shared_services_or_dns_vpc  = true # Specify true or false
        associate_with_dns_vpc_or_a_shared_services_vpc                             = true # Specify true or false
        associate_with_private_hosted_zone_with_centralized_dns_solution            = true # Specify true or false
        create_forwarding_rule_for_sub_domain                                       = false # Specify true or false
        create_forwarding_rule_for_domain                                           = false # Specify true or false
        share_forwarding_rule_with_aws_organization                                 = false # Specify true or false
    }
}
```

G.  Configure the variable *is_centralize_interface_endpoints_available*
    as shown below.


```hcl-terraform
variable "is_centralize_interface_endpoints_available" {
    type = map(bool)
    default = {
        is_centralized_interface_endpoints          = true      # Specify true or false
        associate_with_private_hosted_zones         = true      # Specify true or false
    }
}
```

H.  Finally, configure the variable,
    *attach_to_centralize_dns_solution,* which enables this spoke VPC to
    automatically discover and associate itself with the centralized DNS
    solution being hosted inside the shared services account.

> Please configure the variable *attach_to_centralize_dns_solution* as
> shown below. This concludes the standard *variable.tf* file
> configuration.

```hcl-terraform 
variable "attach_to_centralize_dns_solution"{
    default = true # Specify true or false
}
```

> Next, it's time to configure the *main.tf* file. Open the *main.tf*
> file and perform the steps.

I.  Locate the *spoke_vpc* module inside the *main.tf* file. The perform
    the below configurations:

    # Add a CIDR range for your VPC. There is a default CIDR of 100.65.0.0/16
    
    vpc_cidr_block = "100.65.0.0/16"


II. Add subnets to be used as public subnets. You must add at least two
    > subnets to the list. If you add less than two then terraform will
    > throw an error. This solution is built to create resources
    > according to AWS best practices.

```
public_subnets = ["100.65.1.0/24", "100.65.2.0/24", "100.65.3.0/24"]
```

III. Add your private subnets. Again add at least two subnets to the
     > list.

```
private_subnets = ["100.65.4.0/24", "100.65.5.0/24", "100.65.6.0/24"]
```

IV. Add at least two /28 subnets to be used in the future to host your
    > transit gateway attachment network interfaces.

```    
transit_gateway_subnets = ["100.65.7.0/28", "100.65.8.0/28", "100.65.9.0/28"]
```

> Lastly, add at least one hosted zone to the *private_hosted_zone_name*
> list.
>
``` 
private_hosted_zone_name = ["anaconda.aws-fsf-corp.com"] 
```
>
> This concludes the configuration of this deployment option.

### **Deploying the Integrated Spoke VPC and Shared Services VPC with automated association with centralized DNS and centralized VPC Interface Endpoint resources plus automated integration with the global AWS Transit Gateway Solution.** 

### The steps to deploy this option is very similar to those outlined in *[Deploying the Integrated Spoke VPC and Shared Services VPC with automated association with centralized DNS and centralized VPC Interface Endpoint resources](#deploying-the-integrated-spoke-vpc-and-shared-services-vpc-with-automated-association-with-centralized-dns-and-centralized-vpc-interface-endpoint-resources).*

There are only two additional steps that are required to enable
integration with [the global AWS Transit Gateway
solution](#the-aws-transit-gateway-repository-and-modules).

### That said, please follow all the steps outlined in *[Deploying the Integrated Spoke VPC and Shared Services VPC with automated association with centralized DNS and centralized VPC Interface Endpoint resources](#deploying-the-integrated-spoke-vpc-and-shared-services-vpc-with-automated-association-with-centralized-dns-and-centralized-vpc-interface-endpoint-resources)* but in addition, please perform the following two steps. 

**Step 1: Configure Terraform Remote State Data Source Variables**

To create an AWS Transit Gateway association, each VPC, whether it be a
spoke or shared services VPC, must be aware of the transit gateway and
all the route tables attached to it.

To present this data on each VPC deployment it is recommended that you
first have a transit gateway deployed.

Secondly, take the backend.tf configuration data and configure the below
variables.

```hcl-terraform
#------------------------------------------------------------------------------
# AWS TRANSIT GATEWAY TERRAFORM BACKEND |
#------------------------------------------------------------------------------
variable "tf_backend_s3_bucket_aws_region"{
    default = "PLEASE-ADD-AWS-REGION (example us-east-2)" # Please fill in the aws S3 region where the bucket is being hosted
}

variable "tf_backend_s3_bucket_name"{
    default = "PLEASE-ADD-AWS-BUCKET-NAME"  # Please fill in the aws S3 bucket name that you are using to store terraform state for your shared services
}

variable "tf_backend_state_file_s3_prefixpath_n_key_name"{
    default = "PLEASE-ADD-S3-PREFIX-PATH/KEY-NAME" # The S3 key or prefix+key for the terraform state file
}
```


**Step 2: Enable Actions on the Transit Gateway**

The last variable to configure is the variable
*transit_gateway_association_instructions*. This is a Boolean map that
instructs the solution on how to configure the transit gateway route
tables based on the features you choose to enable. Please see the
required configuration below.

```hcl-terraform

#------------------------------------------------------------------------------
# Transit Gateway Association Task Map
#------------------------------------------------------------------------------
variable "transit_gateway_association_instructions" {
    type = map(bool)
    default = {
        create_transit_gateway_association                              = true      # Specify true or false | Associates VPC with AWS Transit Gateway
        access_shared_services_vpc                                      = true      # Specify true or false | Propagates VPC routes to Shared Services Route Table
        perform_east_west_packet_inspection                             = false     # Specify true or false | Propagates VPC routes to Packet Inspection Route Table for North-South Packet Inspection
        allow_onprem_access_to_entire_vpc_cidr_range                    = false     # Specify true or false | Propagate Routes to On-premises Route Table
        allow_onprem_access_to_externally_routable_vpc_cidr_range       = false     # Specify true or false | Propagate Routes to On-premises Route Table
    }
}
```

This concludes configuration steps. This solution was built to simplify
your journey to AWS. If you wish see certain features added to this
solution then please feel to provide feedback on this solution.

# **Conclusion** 

In conclusion, this solution was designed and built to reduce the time
it takes to go from decision to deploying a network on AWS.

A customer can choose to deploy a global network or a network that is
specific to a single AWS Region. The network you deploy is directly
related to the knobs and switches that you have turned within the
solution.

Please have fun with this solution and feel free to provide feedback
where necessary.
