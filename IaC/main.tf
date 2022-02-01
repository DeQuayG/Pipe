
provider "aws" {
  region   = "us-east-1"
}

terraform {
  required_providers { 
    docker = {
      source = "kreuzwerker/docker"
      version = "2.16.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "3.73.0"
    }
  }
}

## S3 Bucket that will hold scraped data###
## Of course named after the studio that loves to 
## pull at my heart strings (;;)
resource "aws_s3_bucket" "kyoanibuck3t" {
  bucket = "kyoanibuck3t"
  acl    = "public-read"

  tags = {
    Name = "Big Project Bucket"
  }
} 

terraform {
  backend "s3" {
    bucket = "stateful00986"
    key    = "terraform_state"
    region = "us-east-1"
  }
}
