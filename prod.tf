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

# Define our subnet availability zone 1 in N.Virginia region
resource "aws_default_subnet" "default_az1"{
    availability_zone = "us-east-1a"
    tags = {
        "Terraform" : "true"
    }
}

# Define our subnet availability zone 2 in N.Virginia region
resource "aws_default_subnet" "default_az2"{
    availability_zone = "us-east-1b"
    tags = {
        "Terraform" : "true"
    }
}


#adding a security group resources & rules.
resource "aws_security_group" "prod_web" {
    name        = "prod_web" 
    description = "Allow standard http and https ports inbound and everything outbound"

    ingress {
        from_port    = 80
        to_port      = 80
        protocol     = "tcp"
        cidr_blocks  = ["0.0.0.0/0"] 
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

// # Define our instance/server nginx & our security group
// resource "aws_instance" "prod_web" {
//   count = 2

//     ami           = "ami-049f3725664f54adb"
//     instance_type = "t2.micro"
//     tags = {
//         "Terraform" : "true"
//     }
// }

// # Associate & allocate our Elastic IP to our instance
// # This will decouple our EIP , allow flexibility in scaling up
// resource "aws_eip_association" "prod_web" {
//     instance_id    = aws_instance.prod_web.0.id 
//     allocation_id  = aws_eip.prod_web.id
// }

// # Create an Elastic IP
// resource "aws_eip" "prod_web" {
//      tags = {
//         "Terraform" : "true"
//     }
// }

#Define our Elastic Load Balancer  elb
resource "aws_elb" "prob_web" {
    name            = "prod-web-lb"
    #instances      = aws_instance.prod_web.*.id
    subnets         = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
    security_groups = [aws_security_group.prod_web.id]

    listener{
        instance_port     = 80
        instance_protocol = "http"
        lb_port           = 80
        lb_protocol       = "http"
    }
    tags = {
        "Terraform" : "true"
    }
}

# Define an Auto Scaling Group
resource "aws_launch_template" "prod_web" {
  name_prefix   = "prod-web"
  image_id      = "ami-049f3725664f54adb"
  instance_type = "t2.micro"
   tags = {
        "Terraform" : "true"
    }
}

resource "aws_autoscaling_group" "prod_web" {
  availability_zones  = ["us-east-1a", "us-east-1b"]
  vpc_zone_identifier = [aws_default_subnet.default_az1.id,aws_default_subnet.default_az2.id ] 
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.prod_web.id
    version = "$Latest"
  }
  tag {
    key                 = "Terraform" 
    value               = "true"
    propagate_at_launch = true 
  }
 }

# Create a new load balancer attachment
resource "aws_autoscaling_attachment" "prod_web" {
  autoscaling_group_name = aws_autoscaling_group.prod_web.id
  elb                    = aws_elb.prod_web.id
}
