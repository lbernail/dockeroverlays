resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags {
    Name = "${var.vpc_name}"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "demo" {
  count      = "${length(data.aws_availability_zones.available.names)}"
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(var.cidr_block, 8, count.index)}"

  availability_zone       = "${var.az[count.index]}"
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
  count          = "${length(data.aws_availability_zones.available.names)}"
  subnet_id      = "${aws_subnet.demo.*.id[count.index]}"
  route_table_id = "${aws_route_table.public.id}"
}
