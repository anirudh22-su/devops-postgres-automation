output "new_vpc_id" {
  value = aws_vpc.new.id
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "primary_db_ip" {
  value = aws_instance.primary_db.private_ip
}

output "replica_db_ip" {
  value = aws_instance.replica_db.private_ip
}

output "peering_id" {
  value = aws_vpc_peering_connection.peer.id
}
