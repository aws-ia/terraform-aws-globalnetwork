
output "globalnetwork_id" {
  value = aws_cloudformation_stack.create_transit_gateway_network_manager_global_network.outputs["GlobalNetworkId"]
}
