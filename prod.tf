provider "aws" {
    profile = "default"
    region  = "us-east-1"
}

# Define our resource, resouce-type of s3 bucket, & resource name 
resource "aws_s3_bucket" "prod_tf_course" {
    # here we are giving argument unique name/value for our s3 bucket
    bucket = "tf-jldroid-12282020"
    # defines this as a private bucket
    acl    = "private"
}

# we need a vpc  yes we can define on but lets use the aws default one. 
resource "aws_default_vpc" "default" {}

#adding a security group resources & rules.
resource "aws_security_group" "prod_web" {
    name        = "prod_web" 
    description = "Allow standard http and https ports inbound and everything outbound"

    ingress {
        from_port    = 80
        to_port      = 80
        protocol     = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }
#rule for incoming traffic to server we could also use our IP address as well
      ingress {
        from_port    = 443
        to_port      = 443
        protocol     = "tcp"
        cidr_blocks  = ["0.0.0.0/0"]  
    }

#rule for out going traffic from server to the internet
    egress {
        from_port    = 0
        to_port      = 0
        protocol     = "-1"
        cidr_blocks  = ["0.0.0.0/0"]
    }
    tags = {
        "Terraform" : "true"
    }
}

# Define our instance/server nginx & our security group
resource "aws_instance" "prod_web" {
    ami           = "ami-049f3725664f54adb"
    instance_type = "t2.micro"

    tags = {
        "Terraform" : "true"
    }
}

resource "aws_eip" "prod_web"{

    instance = aws_instance.prod_web.id

     tags = {
        "Terraform" : "true"
    }
}
