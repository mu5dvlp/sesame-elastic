output "ec2_public_ip" {
  description = "EIP of the ELK Stack EC2 instance"
  value       = module.sesame_elastic.ec2_public_ip
}

output "kibana_url" {
  description = "Kibana URL"
  value       = module.sesame_elastic.kibana_url
}

output "elasticsearch_url" {
  description = "Elasticsearch URL"
  value       = module.sesame_elastic.elasticsearch_url
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.sesame_elastic.lambda_function_name
}

output "ec2_instance_id" {
  description = "EC2 instance ID (use for SSM Session Manager)"
  value       = module.sesame_elastic.ec2_instance_id
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i sesame-elastic-dev.pem ec2-user@${module.sesame_elastic.ec2_public_ip}"
  sensitive   = false
}
