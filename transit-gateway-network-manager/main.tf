# ------------------------------------------------------------------------------------------
# Transit Gateway Network Manager Creation
# ------------------------------------------------------------------------------------------
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


