variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}

variable "alb_subnet_ids" {
  description = "Subnets for the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for target group"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  default     = "FlaskAppServer"
}
