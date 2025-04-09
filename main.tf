terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.93.0"
    }
  }
}
 
provider "aws" {
  # Configuration options
  region = "us-east-1"

}

#using variable and creating instance
variable "instance_type" {

}

data "aws_ami" "myami" {
  most_recent = true 

  filter{
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }

  filetr{
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]

}


resource "aws_instance" "web" {
  count = 2
  #ami           = "ami-02f624c08a83ca16f"
  ami = data.aws_ami.myami.id  #ami will be fetched from the data source
  instance_type = "t2.micro"

  tags = {
    #Name = "HelloWorld"
    Name = "tf-${count.index}"
  }
}

output "ip" {
  value = aws_instance.web[0].public_ip
}

output "nwinterface" {
  value = aws_instance.web[0].primary_network_interface_id
}

output "ami" {
  value = aws_instance.web[0].ami
}