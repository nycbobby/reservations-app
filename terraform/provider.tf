terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIATZUPZTKPT33VCENR"
  secret_key = "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"
}