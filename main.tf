provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "default"
  }
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags {
    Name = "public"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags {
    Name = "default"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
  tags {
    Name = "public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.1.0/24"
  tags {
    Name = "private"
  }
}

resource "aws_key_pair" "console" {
  key_name = "console"
  public_key = "${file("console.pub")}"
}

resource "aws_spot_instance_request" "console" {
  ami = "ami-6154bb00"
  spot_price = "0.02"
  instance_type = "m3.medium"
  vpc_security_group_ids = ["${aws_security_group.console.id}"]
  key_name = "${aws_key_pair.console.key_name}"
  subnet_id = "${aws_subnet.public.id}"
  tags {
    Name = "console"
  }
}

resource "aws_eip" "console" {
  instance = "${aws_spot_instance_request.console.spot_instance_id}"
  vpc = true
}

resource "aws_route53_record" "console" {
   zone_id = "Z3K6FFH4ISWAX1"
   name = "console.speg03.be"
   type = "A"
   ttl = "300"
   records = ["${aws_eip.console.public_ip}"]
}

resource "aws_security_group" "console" {
  name = "console"
  vpc_id = "${aws_vpc.default.id}"
  description = "console security group"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
