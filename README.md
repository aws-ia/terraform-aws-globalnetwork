**Transitive Architecture**

**for**

**Financial Services**

Androski Spicer

March 2021

# **Contents**

About This Document 3

[Overview 3](#overview)

[Technical Overview 5](#technical-overview)

[The Transitive Network 5](#the-transitive-network)

[Shared Services & Spoke Network Fundamentals
10](#shared-services-spoke-network-fundamentals)

[Architectural Features 10](#architectural-features)

[Shared Services Network 12](#shared-services-network)

[Architectural Features 12](#architectural-features-1)

[Spoke VPC/ Network 15](#spoke-vpc-network)

[Architectural Features 15](#architectural-features-2)

[Conclusion 19](#conclusion)

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
        services that are fundamental to the operation of the overall
        network.

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

variable \"deploy_transit_gateway_in_this_aws_region\" {\
type = map(bool)\
default = {\
all_aws_regions = true \# false\
ohio = false \# true\
n_virginia = false \# true\
oregon = false \# true\
n_california = false \# true\
canada_east = false \# true\
ireland = false \# true\
london = false \# true\
stockholm = false \# true\
frankfurt = false \# true\
paris = false \# true\
tokyo = false \# true\
seoul = false \# true\
sydney = false \# true\
mumbai = false \# true\
singapore = false \# true\
sao-paulo = false \# true\
}\
}

Illustration of a Boolean map that allows customers to specify how their
transit gateways are peered

variable \"transit_gateway_peering\" {\
type = map(bool)\
default = {\
build_complete_mesh = true \# false\
ohio_n\_virginia = false \# true\
ohio_canada_east = false \# true\
ohio_oregon = false \# true\
ohio_n\_california = false \# true\
oregon_n\_california = false \# true\
oregon_canada_east = false \# true\
oregon_n\_virginia = false \# true\
oregon_n\_sao_paulo = false \# true\
oregon_n\_london = false \# true\
\# n_california_canada_east = false \# true\
n_california_n\_virginia = false \# true\
n_virginia_canada_east = false \# true\
n_virginia_n\_london = false \# true\
n_virginia_sao_paulo = false \# true\
london_n\_ireland = false \# true\
london_n\_paris = false \# true\
london_n\_frankfurt = false \# true\
london_n\_milan = false \# true\
london_n\_stockholm = false \# true\
ireland_n\_paris = false \# true\
ireland_n\_frankfurt = false \# true\
ireland_n\_stockholm = false \# true\
frankfurt_n\_stockholm = false \# true\
frankfurt_n\_paris = false \# true\
stockholm_n\_paris = false \# true\
mumbai_n\_frankfurt = false \# true\
mumbai_n\_sao_paulo = false \# true\
mumbai_n\_tokyo = false \# true\
mumbai_n\_seoul = false \# true\
mumbai_n\_singapore = false \# true\
mumbai_n\_sydney = false \# true\
singapore_n\_sydney = false \# true\
singapore_n\_tokyo = false \# true\
singapore_n\_sao_paulo = false \# true\
singapore_n\_seoul = false \# true\
sydney_n\_seoul = false \# true\
sydney_n\_tokyo = false \# true\
sydney_n\_sao_paulo = false \# true\
tokyo_n\_seoul = false \# true\
tokyo_n\_sao_paulo = false \# true\
paris_n\_sao_paulo = false \# true\
}\
}

Illustration of a global transit gateways network all connected using
transit gateway peering

![](media/image1.png){width="6.75in" height="4.4319444444444445in"}

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

![](media/image2.png){width="6.75in" height="4.240277777777778in"}

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
these security groups are controlled by a Boolean map and the ports by
another.

Today, a customer can create the following security groups :

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

![](media/image3.png){width="6.75in" height="3.7916666666666665in"}

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

![](media/image4.png){width="6.75in" height="4.216666666666667in"}

![](media/image5.png){width="6.75in" height="3.6847222222222222in"}

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

# **Conclusion**

In conclusion, this solution was designed and built to reduce the time
it takes to go from decision to deploying a network on AWS.

A customer can choose to deploy a global network or a network that is
specific to a single AWS Region. The network you deploy is directly
related to the knobs and switches that you have turned within the
solution.