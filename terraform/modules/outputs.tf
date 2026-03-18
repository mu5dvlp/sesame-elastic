output "ec2_public_ip" {
  description = "EIP of the ELK Stack EC2 instance"
  value       = aws_eip.elk.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.elk.id
}

output "kibana_url" {
  description = "Kibana URL"
  value       = "http://${aws_eip.elk.public_ip}:5601"
}

output "elasticsearch_url" {
  description = "Elasticsearch URL"
  value       = "http://${aws_eip.elk.public_ip}:9200"
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.sesame_monitor.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.sesame_monitor.arn
}

output "private_key_path" {
  description = "Path to the generated SSH private key"
  value       = local_sensitive_file.elk_private_key.filename
  sensitive   = true
}

output "elk_version" {
  description = "ELK Stack version"
  value       = var.elk_version
}
