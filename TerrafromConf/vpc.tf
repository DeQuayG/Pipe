#VPC 
resource "aws_vpc" "big_project_vpc" {
  cidr_block = var.vpc_cidr 
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway = true
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "terraform_vpc"
    Terraform = "true"
  }
}

resource "aws_subnet" "ecs_subnet" {
    vpc_id = aws_vpc.big_project_vpc.id
    cidr_block = var.private_cidrs[0]

    tags = {
      Name = ecs_subnet
    }
} 

resource "aws_subnet" "data_subnet" {
    vpc_id = aws_vpc.big_project_vpc.id
    cidr_block = var.private_cidrs[1]

    tags = {
      Name = data_subnet
    }
}
resource "aws_subnet" "elb_pub_subnet" {
    vpc_id = aws_vpc.big_project_vpc.id
    cidr_block = "10.10.10.0/28"
    map_public_ip_on_launch = true
    availability_zone = var.az[0] 

    tags = { 
      Name = alb
    }
} 

resource "aws_internet_gateway" "gateway_of_last_resort" {
    vpc_id = aws_vpc.big_project_vpc.id

    tags = {
        Name = "bp_igw"
    }
}

resource "aws_route_table" "all_traffic" {
    vpc_id = aws_vpc.big_project_vpc.id


resource "aws_route" "default_route" {
        route_table_id = aws_route_table.all_traffic.id
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gateway_of_last_resort.id
    }
}

resource "aws_route_table_association" "subnet_association" {
    subnet_id      = aws_subnet.elb_pub_subnet.id
    route_table_id = aws_route_table.all_traffic.id
}

resource "aws_route_table_association" "subnet_association" {
    subnet_id      = aws_subnet.data_subnet.id
    route_table_id = aws_route_table.all_traffic.id
} 

resource "aws_route_table_association" "subnet_association" {
    subnet_id      = aws_subnet.ecs_subnet.id
    route_table_id = aws_route_table.all_traffic.id
}