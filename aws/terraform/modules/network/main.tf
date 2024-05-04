
variable "cidr_block" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "name_prefix" {
  type    = string
  default = "TF"
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_vpc" "fancy_assed_vpc" {
  cidr_block = var.cidr_block

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name_prefix} - james' packer testing VPC"
  }
}

resource "aws_internet_gateway" "gw" {
  tags = {
    Name = "${var.name_prefix} - packer testing igw"
  }
}

resource "aws_internet_gateway_attachment" "gw" {
  internet_gateway_id = aws_internet_gateway.gw.id
  vpc_id              = aws_vpc.fancy_assed_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.fancy_assed_vpc.id

  tags = {
    Name = "${var.name_prefix} - packer testing public RT"
  }
}

resource "aws_route" "public_igw_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id     = aws_vpc.fancy_assed_vpc.id
  cidr_block = var.private_subnets[count.index]

  tags = {
    Name = "${aws_vpc.fancy_assed_vpc.tags.Name} private subnet ${count.index}"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.fancy_assed_vpc.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true

  tags = merge({
    Name = "${aws_vpc.fancy_assed_vpc.tags.Name} public subnet ${count.index}"
  }, var.tags)
}

resource "aws_route_table_association" "public_association" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

output "vpc" {
  value = aws_vpc.fancy_assed_vpc
}

output "public_subnets" {
  value = aws_subnet.public
}

output "private_subnets" {
  value = aws_subnet.private
}
