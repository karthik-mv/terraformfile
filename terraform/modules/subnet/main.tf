//subnet
resource "aws_subnet" "mysubnet" {
  vpc_id     = var.vpc_id
  #cidr_block = "10.0.1.0/24"
  cidr_block = var.subnet_cidr_block
  availability_zone = var.az #"us-east-1b"

  tags = {
    Name =  "${var.env}-subnet" #"my-subnet"
  }
}


//internet gateway
resource "aws_internet_gateway" "myigw" {
  vpc_id = var.vpc_id

  tags = {
    Name =  "${var.env}-igw" #"my-igw"
  }
}

// route table

resource "aws_route_table" "myrt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"  #"10.0.1.0/24"
    gateway_id = aws_internet_gateway.myigw.id
  }

  tags = {
    Name =  "${var.env}-rt" #"my-rt"
  }
}

//route table association

resource "aws_route_table_association" "amyrta" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myrt.id
}
