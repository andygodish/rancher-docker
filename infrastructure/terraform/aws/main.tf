provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "server" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t2.2xlarge"
  vpc_security_group_ids = [
    aws_security_group.server_sg.id ##### This creates an implicit dependency, meaning that the sg will be created first 
  ]

  # Demonstration of interpolation below
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} & 
              EOF
  tags = {
    Name = "Rancher Server in Docker"
  }
}

output "public_ip" {
  value = aws_instance.server.public_ip
}

# A security group resource exports an attribute called id - use this expression 
# in your instance resource
resource "aws_security_group" "server_sg" {
  name = "Rancher Server in Docker Security Group"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_lb" "load_balancer" {
  name               = "rancher-server-in-docker-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups = [
    aws_security_group.alb.id
  ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "alb" {
  name = "alb-security-group"

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
