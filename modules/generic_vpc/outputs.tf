output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs in Availability Zone order."
  value       = [for index in sort(keys(aws_subnet.private)) : aws_subnet.private[index].id]
}

output "isolated_subnet_ids" {
  description = "Isolated subnet IDs in Availability Zone order."
  value       = [for index in sort(keys(aws_subnet.isolated)) : aws_subnet.isolated[index].id]
}

output "private_route_table_ids" {
  description = "Private route table IDs."
  value       = [for index in sort(keys(aws_route_table.private)) : aws_route_table.private[index].id]
}

output "isolated_route_table_ids" {
  description = "Isolated route table IDs."
  value       = [for index in sort(keys(aws_route_table.isolated)) : aws_route_table.isolated[index].id]
}
