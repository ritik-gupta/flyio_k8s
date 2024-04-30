terraform {

  #   cloud {
  #     organization = "supamakers"
  #     workspaces {
  #       name = "saasmaker-$main"
  #     }
  #   }

  backend "s3" {
    bucket         = "tfstatebuckettest"
    key            = "fargate_module.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraformstatetable"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.45.0"
    }
  }
  required_version = "~> 1.3"
}
