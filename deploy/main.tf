provider "aws" {
  region = "us-east-1"
}

# 1.- Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "production"
  }
}
# 2.- Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}
# 3.- Create Custom Route Table
resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Prod"
  }

}
# 4.- Create a Subnet
resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.main.id
  # cidr_block = "10.0.1.0/24"
  cidr_block        = var.subnet_prefix
  availability_zone = "us-east-1"

  tags = {
    Name = "prod-subnet"
  }
}
# 5.- Associate Subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.r.id
}
# 6.- Create Security Group to allow port 22, 80, 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}
# 7.- Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web-server" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}
# 8.- Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

# 9.- Create Ubuntu server and install/enable apache2

resource "aws_instance" "ubuntu-server" {
  ami               = "ami-XXX"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server.id
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo bash -c 'echo your very first web server > /var/www/html/index.html'
    EOF

  tags = {
    Name = "web-server"
  }
}

# Print at the end console when type apply
output "server_public_ip" {
  value = aws_eip.one.public_ip
}

# Variable
variable "subnet_prefix" {
  description = "cidr block for the subnet"
  # default = "10.0.66.0/24"
  type = string
}