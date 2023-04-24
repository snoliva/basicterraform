# Create VPC 
resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-vpc" })
  )  
}

# Create Internet Gateway and associate to VPC

resource "aws_internet_gateway" "igw-main-vpc" {
  vpc_id = aws_vpc.main

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-vpc" })
  )
}

####################################################
# Public Subnet - Inbound/Outbound Internet Acces #
####################################################

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true # indicate that instances launched into the subnet should be assigned a public IP
  availability_zone = "us-east-1a"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public" })
  )

}

resource "aws_route_table" "public-subnet" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public" })
  )
}

resource "aws_route_table_association" "public-subnet" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-subnet
}

resource "aws_route" "public_internet_access" {
  route_table_id = aws_route_table.public-subnet.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw-main-vpc.id
}

resource "aws_eip" "public" {
  vpc = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public" })
  )
}

resource "aws_nat_gateway" "public-subnet" {
  allocation_id = aws_eip.public.id
  subnet_id = aws_subnet.public-subnet.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public" })
  )
}

####################################################
# Private Subnet                                   #
####################################################

resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "us-east-1b"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private" })
  )
}

resource "aws_route_table" "private-subnet" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private" })
  )
}

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-subnet.id
}

####################################################
#                Security Group                    #
####################################################

