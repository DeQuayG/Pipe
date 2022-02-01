resource "aws_vpc" "app_vpc" {
  cidr_block = "172.16.0.0/24"
}

## It is AWS Best Practice to have multiple private and public
## Subnets in different availability zones for HA
## A /24 can be broken up into 2 /25's or 4 /26's (Dotted Decimal: 255.255.255.192)
resource "aws_subnet" "public_sub_1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "172.16.0.0/26"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "public subnet 1"
  }
}

resource "aws_subnet" "private_ecs_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "172.16.0.64/26"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "private ecs subnet"
  }
}

resource "aws_subnet" "public_sub_2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "172.16.0.128/26"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "public subnet 2"
  }
}

resource "aws_subnet" "private_data_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "172.16.0.192/26"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "private data subnet"
  }
}

##########Just a segmentation Marker, make it easier to read###########

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    "Name" = "public route table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    "Name" = "private route table"
  }
}

resource "aws_route_table_association" "public_sub_1" {
  subnet_id      = aws_subnet.public_sub_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_ecs_subnet" {
  subnet_id      = aws_subnet.private_ecs_subnet.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public_sub_2" {
  subnet_id      = aws_subnet.public_sub_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_data_subnet" {
  subnet_id      = aws_subnet.private_data_subnet.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id
}

## Here we associate the NAT Gateway with the Public Subnet
## This may seem counter-intuitive since we created it to keep the IP's private,
## but the Public Subnet is essentially the "exit", and all traffic that doesn't 
## have a local destination IP, will automatically be routed out of the IGW
resource "aws_nat_gateway" "nat_gw" {
  subnet_id     = aws_subnet.public_sub_1.id
  allocation_id = aws_eip.nat.id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_security_group" "http" {
  name        = "http:80"
  description = "HTTP VPC traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  egress {
      from_port   = 80
      to_port     = 80
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


resource "aws_security_group" "egress_all" {
  name        = "egress-all"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.app_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "instance_sg" {
  description = "controls direct access to application instances"
  vpc_id      = aws_vpc.app_vpc.id
  name        = "application-instances-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 32768
    to_port     = 65535
    description = "Access from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}