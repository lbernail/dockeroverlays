resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "demo" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.cidr_block}"

  availability_zone       = "${var.az}"
  map_public_ip_on_launch = "true"

  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.vpc_name} Gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.vpc_name} Public"
  }
}

resource "aws_route" "public_default" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_route_table_association" "rtap" {
  subnet_id      = "${aws_subnet.demo.id}"
  route_table_id = "${aws_route_table.public.id}"
}
