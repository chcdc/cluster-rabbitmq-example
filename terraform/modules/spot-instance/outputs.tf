output "instance_id" {
  description = "ID of the spot instance"
  value       = aws_spot_instance_request.this.spot_instance_id
}

output "public_ip" {
  description = "Public IP of the spot instance"
  value       = aws_spot_instance_request.this.public_ip
}

output "private_ip" {
  description = "Private IP of the spot instance"
  value       = aws_spot_instance_request.this.private_ip
}
