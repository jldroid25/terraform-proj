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