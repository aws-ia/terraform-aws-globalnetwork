
output "transit_gateway_peering_attachment_id" {
  value = concat(aws_ec2_transit_gateway_peering_attachment.transit_gateway_peering_request.*.id, [null])[0]
}
