data "aws_ami" "amazon_linux2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"] 
  }

  filter {
    name   = "architecture"
    values = ["x86_64"] # Use "arm64" if using a Graviton instance type like t4g
  }
}


data "aws_vpc" "main" {
  id = "vpc-071dc429d54e64259"
}

data "aws_subnet" "public" {
  id = "subnet-07fe08d5909e677db"
}

data "aws_caller_identity" "current" {

}

data "aws_region" "current" {

}