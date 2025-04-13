data "aws_ami" "myami" {
  most_recent = true 

  filter{
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }

  filter{
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]

}


//security group
resource "aws_security_group" "mywebsecurity" {
  name        = "mysecurityrules"
  description = "Allow TLS inbound traffic"
  vpc_id      =  var.vpc_id    #aws_vpc.myvpc.id     #"${aws_vpc.main.id}"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //ingress means inbound rules
  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env}-sg"
  }
}

resource "aws_instance" "web" {
  #count = 2
  #ami           = "ami-02f624c08a83ca16f"
  ami = data.aws_ami.myami.id  #ami will be fetched from the data source
  instance_type = var.instance_type                  # "t2.micro"

    associate_public_ip_address = true
    subnet_id = var.subnet_id #aws_subnet.mysubnet.id
    vpc_security_group_ids = [aws_security_group.mywebsecurity.id]
    key_name = "Kubernetes" #check the key name from the instance key name column
    user_data=file("server-script.sh")

  tags = {
    Name = "${var.env}-webserver"
    #Name = "tf-${count.index}"
    #Name = "tf-${terraform.workspace}"
  }
}
