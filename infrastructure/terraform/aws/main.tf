provider "aws" {
    region = "us-east-2"
}

resource "aws_instance" "server" {
    ami = "ami-09e67e426f25ce0d7"
    instance_type = "t2.2xlarge"
}

