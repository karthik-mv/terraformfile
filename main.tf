terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.93.0"
    }
  }

  # backend "s3" {
  #   bucket = "terraform-bucket93"
  #   key    = "terraform.tfstate"
  #   region = "us-east-1"
  #   dynamodb_table = "aws-table"
  # }
}
 
provider "aws" {
  # Configuration options
  region = "us-east-1"

}


#Vpc

resource "aws_vpc" "myvpc" {
  cidr_block       = var.vpc_cidr_block  #"10.0.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}

module "mysubnet"{
  source = "./modules/subnet"
  vpc_id = aws_vpc.myvpc.id
  subnet_cidr_block = var.subnet_cidr_block
  az = var.az
  env = var.env
}

module "webserver"{
  source = "./modules/webserver"
  vpc_id = aws_vpc.myvpc.id
  subnet_id = module.mysubnet.subnet.id
  env = var.env
  instance_type = var.instance_type
}



# output "ip" {
#   value = aws_instance.web[0].public_ip
# }

# output "nwinterface" {
#   value = aws_instance.web[0].primary_network_interface_id
# }

# output "ami" {
#   value = aws_instance.web[1].ami
# }