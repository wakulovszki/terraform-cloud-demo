data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "wakulovszki"
    workspaces = {
      name = "VPC"
    }
  }
}



resource "aws_db_subnet_group" "default" {
  name       = "project-db-subnet-group"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets
}