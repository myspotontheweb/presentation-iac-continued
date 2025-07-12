terraform {
  required_version = ">= 1.10.1"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
  }

  backend "s3" {
    bucket  = "my-tf-test-bucket-backend-20233"
    key     = "state/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }  
}

provider "aws" {
  region = var.region
}
