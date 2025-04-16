provider "aws" {
  region = var.region
}

# 🌐 Internet Gateway for VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "flask-vpc-igw"
  }
}

# 🛣️ Public Route Table with route to IGW
resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "flask-public-rt"
  }
}

# 🔗 Associate Route Table with ALB subnets
resource "aws_route_table_association" "alb_subnet_1" {
  subnet_id      = "subnet-024d1f3b264836506"
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "alb_subnet_2" {
  subnet_id      = "subnet-004f09fa908d55780"
  route_table_id = aws_route_table.public_rt.id
}

# 🔐 Security Group for EC2 Instance (Flask App)
resource "aws_security_group" "flask_sg" {
  name        = "flask-security-group"
  description = "Allow SSH and app traffic from ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "Allow traffic from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🔐 Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Allow HTTP from internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🚀 EC2 Instance with Dockerized Flask App
resource "aws_instance" "flask_ec2" {
  ami                         = var.ami_id  
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.flask_sg.id]
  associate_public_ip_address = true  # ✅ Ensure EC2 gets a public IP

  tags = {
    Name = var.instance_name
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker run -d -p 5000:5000 omkarsg07/flask-app:latest
            EOF
}

# 🌐 Application Load Balancer (ALB)
resource "aws_lb" "flask_alb" {
  name               = "flask-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.alb_subnet_ids
}

# 🎯 Target Group for Flask App
resource "aws_lb_target_group" "flask_tg" {
  name        = "flask-target-group"
  port        = 5000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

# 🔗 Attach EC2 Instance to Target Group
resource "aws_lb_target_group_attachment" "flask_attach" {
  target_group_arn = aws_lb_target_group.flask_tg.arn
  target_id        = aws_instance.flask_ec2.id
  port             = 5000
}

# 🔉 ALB Listener (HTTP:80)
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.flask_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_tg.arn
  }
}
