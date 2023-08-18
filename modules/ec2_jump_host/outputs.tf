output "instance_id" {
  value = module.ec2_instance.id
}

output "security_group_id" {
  value = aws_security_group.jump_host_sg.id
}
