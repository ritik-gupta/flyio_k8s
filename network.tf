resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "http" {
  description = "Permit incoming HTTP traffic"
  name        = "http"
  vpc_id      = resource.aws_vpc.this.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "TCP"
    to_port     = 80
  }
}

resource "aws_security_group" "https" {
  description = "Permit incoming HTTPS traffic"
  name        = "https"
  vpc_id      = resource.aws_vpc.this.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    protocol    = "TCP"
    to_port     = 443
  }
}

resource "aws_security_group" "egress_all" {
  description = "Permit all outgoing traffic"
  name        = "egress-all"
  vpc_id      = resource.aws_vpc.this.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

resource "aws_security_group" "ingress_api" {
  description = "Permit some incoming traffic"
  name        = "ingress-esc-service"
  vpc_id      = resource.aws_vpc.this.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "TCP"
    to_port     = 0
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_internet_gateway" "this" {
  vpc_id = resource.aws_vpc.this.id
}

# * Create public subnetworks (Public Subnets) that are exposed to the interent
# * so that we can make and take requests.
resource "aws_route_table" "public" {
  vpc_id = resource.aws_vpc.this.id
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = resource.aws_internet_gateway.this.id
  route_table_id         = resource.aws_route_table.public.id
}

resource "aws_subnet" "public" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(resource.aws_vpc.this.cidr_block, 8, count.index)
  vpc_id            = resource.aws_vpc.this.id
}

resource "aws_route_table_association" "public" {
  for_each = { for k, v in resource.aws_subnet.public : k => v.id }

  route_table_id = resource.aws_route_table.public.id
  subnet_id      = each.value
}

resource "aws_eip" "this" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = resource.aws_eip.this.id
  subnet_id     = resource.aws_subnet.public[0].id

  depends_on = [resource.aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  vpc_id = resource.aws_vpc.this.id
}

resource "aws_route" "private" {
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = resource.aws_nat_gateway.this.id
  route_table_id         = resource.aws_route_table.private.id
}

resource "aws_subnet" "private" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(resource.aws_vpc.this.cidr_block, 8, count.index + length(resource.aws_subnet.public))
  vpc_id            = resource.aws_vpc.this.id
}

resource "aws_route_table_association" "private" {
  for_each = { for k, v in resource.aws_subnet.private : k => v.id }

  route_table_id = resource.aws_route_table.private.id
  subnet_id      = each.value
}
