variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
}

variable "instance_type" {
  default     = "t2.micro"
  description = "EC2 instance type"
}

variable "key_name" {
  description = "SSH key pair"
  type        = string
}

variable "allowed_ssh_ip" {
  default     = "0.0.0.0/0"
  description = "CIDR for SSH access"
}

variable "instance_name" {
  default     = "FlaskAppServer"
}

variable "docker_image" {
  default     = "omkarsg07/flask-app"
}

variable "docker_tag" {
  default     = "latest"
}
