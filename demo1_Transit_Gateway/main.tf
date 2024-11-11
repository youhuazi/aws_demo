terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-1"
}

# Create a VPC
resource "aws_vpc" "vpc_01" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc_01"
  }
}

resource "aws_subnet" "vpc_01_main_subnet" {
  vpc_id     = aws_vpc.vpc_01.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "vpc_01_main_subnet"
  }
}

# Create a VPC
resource "aws_vpc" "vpc_02" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "vpc_02"
  }
}

resource "aws_subnet" "vpc_02_main_subnet" {
  vpc_id     = aws_vpc.vpc_02.id
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "vpc_02_main_subnet"
  }
}

resource "aws_ec2_transit_gateway" "transit_gateway_for_vpc_01_and_vpc_02" {
  description = "connect vpc_01 and vpc_02 by transit_gateway"
  tags = {
    Name = "transit_gateway_for_vpc_01_and_vpc_02"
  }
}

resource "aws_ec2_transit_gateway_route_table" "transit_gateway_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway_for_vpc_01_and_vpc_02.id
  tags = {
    Name = "transit_gateway_route_table_01"
  }
}

resource "aws_ec2_transit_gateway_default_route_table_association" "default_route_table_association" {
  transit_gateway_id             = aws_ec2_transit_gateway.transit_gateway_for_vpc_01_and_vpc_02.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit_gateway_route_table.id
}

resource "aws_ec2_transit_gateway_default_route_table_propagation" "default_route_table_propagation" {
  transit_gateway_id             = aws_ec2_transit_gateway.transit_gateway_for_vpc_01_and_vpc_02.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit_gateway_route_table.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_attachment_vpc_01_main_subnet" {
  subnet_ids                                      = [aws_subnet.vpc_01_main_subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.transit_gateway_for_vpc_01_and_vpc_02.id
  transit_gateway_default_route_table_association = false
  vpc_id                                          = aws_vpc.vpc_01.id
  tags = {
    Name = "transit_gateway_attachment_01"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_attachment_vpc_02_main_subnet" {
  subnet_ids                                      = [aws_subnet.vpc_02_main_subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.transit_gateway_for_vpc_01_and_vpc_02.id
  transit_gateway_default_route_table_association = false
  vpc_id                                          = aws_vpc.vpc_02.id
  tags = {
    Name = "transit_gateway_attachment_02"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "transit_gateway_route_table_association_vpc_02_main_subnet" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment_vpc_02_main_subnet.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit_gateway_route_table.id
}

resource "aws_ec2_transit_gateway_route_table_association" "transit_gateway_route_table_association_vpc_01_main_subnet" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment_vpc_01_main_subnet.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit_gateway_route_table.id
}