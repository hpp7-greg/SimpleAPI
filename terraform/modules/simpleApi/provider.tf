terraform {
  backend "s3" {
    bucket = "simple-api-tf-state"
    key    = "simple-api"
    region = "us-east-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    # configure docker provider
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "docker" {
  registry_auth {
      address = data.aws_ecr_authorization_token.token.proxy_endpoint
      username = data.aws_ecr_authorization_token.token.user_name
      password  = data.aws_ecr_authorization_token.token.password
    }
}