terraform {

  backend "s3" {
    bucket         = "tfstatebuckettest"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraformstatetable"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.32.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }
  required_version = "~> 1.3"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}