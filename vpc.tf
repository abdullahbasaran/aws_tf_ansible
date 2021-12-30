# Create the VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.vpc_name}-vpc" }


}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
  #   tags = var.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  # tags = var.tags
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_web[0].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  vpc = true
  # tags = var.tags
}
resource "aws_nat_gateway" "gw" {
  depends_on    = [aws_internet_gateway.gw]
  allocation_id = aws_eip.nat.id
  count         = length(var.azs)
  subnet_id     = aws_subnet.public_web[count.index].id
  # tags = var.tags
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my_vpc.id
  count  = length(var.azs)
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw[count.index].id
  }
  # tags = var.tags
}


resource "aws_route_table_association" "private1" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.private_application[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "private2" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.private_dbms[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Create the public subnets
resource "aws_subnet" "public_web" {
  count = length(var.public_subnets_cidrs)

  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnets_cidrs[count.index]
  availability_zone       = "${var.aws_region}${var.azs[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-web-${var.azs[count.index]}"
  }
}


# Create the private subnets
resource "aws_subnet" "private_application" {
  count = length(var.public_subnets_cidrs)

  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnets_cidrs[count.index]
  availability_zone       = "${var.aws_region}${var.azs[count.index]}"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-private-application-${var.azs[count.index]}"
  }
}

resource "aws_subnet" "private_dbms" {
  count = length(var.public_subnets_cidrs)

  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.private_subnets_cidrs2[count.index]
  availability_zone       = "${var.aws_region}${var.azs[count.index]}"
  map_public_ip_on_launch = false

  tags = {
    # Name = "${var.vpc_name}-private-dbms-${var.azs[count.index]}"
  }
}
