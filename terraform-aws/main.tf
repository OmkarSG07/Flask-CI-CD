provider "aws" {
  region = var.region  # Specify the AWS region for resources
}

# VPC (Virtual Private Cloud) creation
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # Define the CIDR block for the VPC

  tags = {
    Name = "flask-vpc"  # Name of the VPC for easy identification
  }
}

# Internet Gateway to allow the VPC to connect to the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id  # Attach the gateway to the main VPC

  tags = {
    Name = "flask-vpc-igw"  # Name the Internet Gateway
  }
}

# Public Subnet 1 in Availability Zone 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id  # Link to the VPC
  cidr_block              = "10.0.1.0/24"  # CIDR block for the subnet
  availability_zone       = data.aws_availability_zones.available.names[0]  # Availability zone
  map_public_ip_on_launch = true  # Automatically assign public IPs

  tags = {
    Name = "public-subnet-1"  # Name for the subnet
  }
}

# Public Subnet 2 in Availability Zone 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

# Fetch available availability zones in the region
data "aws_availability_zones" "available" {}

# Route Table for public subnets to allow internet access
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id  # Attach to the main VPC

  route {
    cidr_block = "0.0.0.0/0"  # Allow all traffic to the internet
    gateway_id = aws_internet_gateway.igw.id  # Use the IGW for outbound traffic
  }

  tags = {
    Name = "flask-public-rt"  # Name for the route table
  }
}

# Associate the public subnet 1 with the route table
resource "aws_route_table_association" "assoc_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate the public subnet 2 with the route table
resource "aws_route_table_association" "assoc_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group for EC2 instances, allowing SSH and app traffic (port 5000)
resource "aws_security_group" "flask_sg" {
  name        = "flask-sg"  # Name for the security group
  vpc_id      = aws_vpc.main.id
  description = "Allow SSH and app traffic"

  # Ingress rule for SSH (port 22) from a specific IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_ip]  # Specify allowed IP for SSH access
  }

  # Ingress rule for HTTP traffic on port 5000 (Flask app)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow access from anywhere
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# Security Group for the Application Load Balancer (ALB)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow HTTP traffic on port 80"

  # Ingress rule for HTTP traffic (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP access from anywhere
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance running the Flask app
resource "aws_instance" "flask_ec2" {
  ami                    = var.ami_id  # AMI for the EC2 instance
  instance_type          = var.instance_type  # Instance type (e.g., t2.micro)
  key_name               = var.key_name  # SSH key for accessing the EC2
  subnet_id              = aws_subnet.public_subnet_1.id  # Attach EC2 to subnet 1
  vpc_security_group_ids = [aws_security_group.flask_sg.id]  # Associate the EC2 with the Flask SG
  associate_public_ip_address = true  # Associate a public IP with the EC2 instance

  # User data to install Docker and run Flask app in a Docker container
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker run -d -p 5000:5000 ${var.docker_image}:${var.docker_tag}
              EOF

  tags = {
    Name = var.instance_name  # Name of the EC2 instance
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "flask_alb" {
  name               = "flask-alb"
  internal           = false  # Set to false for public-facing ALB
  load_balancer_type = "application"  # Type of load balancer
  security_groups    = [aws_security_group.alb_sg.id]  # Associate the ALB SG
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]  # Use public subnets
}

# Target Group for ALB, routing traffic to the Flask app on port 5000
resource "aws_lb_target_group" "flask_tg" {
  name        = "flask-tg"  # Name for the target group
  port        = 5000  # Flask app runs on port 5000
  protocol    = "HTTP"
  target_type = "instance"  # Targets are EC2 instances
  vpc_id      = aws_vpc.main.id  # Attach target group to the VPC
}

# Attach the Flask EC2 instance to the target group
resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.flask_tg.arn
  target_id        = aws_instance.flask_ec2.id
  port             = 5000  # Forward traffic on port 5000
}

# ALB listener to route incoming traffic on port 80 to the target group
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.flask_alb.arn  # Attach listener to ALB
  port              = 80  # Listen on port 80 (HTTP)
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_tg.arn  # Forward traffic to the target group
  }
}
