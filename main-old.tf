provider "aws"{
    region = "us-east-1"
}

resource "aws_instance" "flask_ec2" {
    ami = "ami-084568db4383264d4"
    instance_type = "t2.micro"
    key_name = "12dayChallenge"

    security_groups = [ aws_security_group.flask_sg.name ]

    tags = {
        Name = "FlaskAppServer"
    }
}
resource "aws_security_group""flask_sg" {
    name        = "flask-security-group"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (restrict in real-world)
    }
    ingress {
        from_port   = 5000
        to_port     = 5000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Allow Flask traffic
    }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



