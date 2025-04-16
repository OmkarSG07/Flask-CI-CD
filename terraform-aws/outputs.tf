output "ec2_public_ip" {
  description = "Public IP of the Flask EC2 instance"
  value       = aws_instance.flask_ec2.public_ip
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.flask_alb.dns_name
}
