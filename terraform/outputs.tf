output "debian_instance_ids" {
  description = "IDs of the Debian spot instances"
  value       = module.debian_instances[*].instance_id
}

output "debian_public_ips" {
  description = "Public IPs of the Debian spot instances"
  value       = module.debian_instances[*].public_ip
}

output "debian_private_ips" {
  description = "Private IPs of the Debian spot instances"
  value       = module.debian_instances[*].private_ip
}

output "debian_master_private_ips" {
  description = "Private IPs of the Debian spot instances"
  value       = module.debian_instances_master[*].private_ip
}

output "debian_master_public_ips" {
  description = "Public IPs of the Debian spot instances"
  value       = module.debian_instances_master[*].public_ip
}