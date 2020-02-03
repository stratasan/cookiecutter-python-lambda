provider "aws" {
  version = "~> 2.0"
}

terraform {
  backend "s3" {
    bucket = "{{cookiecutter.terraform_bucket}}"
    key    = "lambda/{{cookiecutter.name}}/terraform.tfstate"
    region = "{{cookiecutter.region}}"
  }
}

# SNS Topic pushing messages to our queue
data "terraform_remote_state" "TOPIC" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    key    = "sns/{{cookiecutter.sns_topic_name}}/terraform.tfstate"
    bucket = "{{cookiecutter.terraform_bucket}}"
    region = "{{cookiecutter.region}}"
  }
}

# Global failures queue
data "terraform_remote_state" "failures-queue" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    key    = "sqs/failures/terraform.tfstate"
    bucket = "{{cookiecutter.terraform_bucket}}"
    region = "{{cookiecutter.region}}"
  }
}

data "terraform_remote_state" "dev-vpc" {
  backend = "s3"
  config = {
    bucket = "{{cookiecutter.terraform_bucket}}"
    key    = "ops/vpc/staging/terraform.tfstate"
    region = "{{cookiecutter.region}}"
  }
}

data "terraform_remote_state" "prod-vpc" {
  backend = "s3"
  config = {
    bucket = "{{cookiecutter.terraform_bucket}}"
    key    = "ops/vpc/prod/terraform.tfstate"
    region = "{{cookiecutter.region}}"
  }
}

data "terraform_remote_state" "function_layer" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    key    = "lambda/shared_layer/terraform.tfstate"
    bucket = "{{cookiecutter.terraform_bucket}}"
    region = "{{cookiecutter.region}}"
  }
}

