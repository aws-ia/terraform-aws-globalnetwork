output "transit_gateway_id" {
  value = concat(aws_ec2_transit_gateway.transit_gateway.*.id, [null])[0]
}

output "transit_gateway_arn" {
  value = concat(aws_ec2_transit_gateway.transit_gateway.*.arn, [null])[0]
}

output "transit_gateway_owner_id" {
  value = concat(aws_ec2_transit_gateway.transit_gateway.*.owner_id, [null])[0]
}


output "shared_services_route_table_id" {
  value = concat(aws_ec2_transit_gateway_route_table.shared_services_route_table.*.id, [null])[0]
}

output "north_south_route_table_id" {
  value = concat(aws_ec2_transit_gateway_route_table.north_south_route_table.*.id, [null])[0]
}

output "packet_inspection_route_table_id" {
  value = concat(aws_ec2_transit_gateway_route_table.packet_inspection_route_table.*.id, [null])[0]
}

output "development_route_table_id" {
  value = concat(aws_ec2_transit_gateway_route_table.development_route_table.*.id, [null])[0]
}

output "production_route_table_id" {
  value = concat(aws_ec2_transit_gateway_route_table.production_route_table.*.id, [null])[0]
}

output "uat_route_table_id" {
  value = concat(aws_ec2_transit_gateway_route_table.uat_route_table.*.id, [null])[0]
}

