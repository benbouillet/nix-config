output "nebula_endpoint" {
  value = var.create_instance ? "${aws_eip.tarkin.public_ip}:4242" : null
}

output "instance_id" {
  value = var.create_instance ? aws_instance.nixos_arm64[0].id : null
}

output "elastic_ip" {
  value = aws_eip.tarkin.public_ip
}

output "secret_name" {
  value = aws_secretsmanager_secret.age.name
}

output "secret_arn" {
  value = aws_secretsmanager_secret.age.arn
}

output "ssm_ssh_target" {
  value = var.create_instance ? "aws ssm start-session --target ${aws_instance.nixos_arm64[0].id} --document-name AWS-StartSSHSession --parameters portNumber=22" : null
}
