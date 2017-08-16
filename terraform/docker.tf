resource "aws_security_group" "docker" {
  name        = "docker-servers"
  description = "Access to docker servers"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    self        = "true"
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    self        = "true"
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    self        = "true"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "Docker"
  }
}

data "template_file" "setup_docker0" {
    template     = "${file("${path.module}/files/setup_docker.tpl.sh")}"
    vars {
        TF_HOSTNAME = "docker0"
        TF_HOST_IP = "${var.docker0_ip}"
        TF_CONSUL_IP = "${aws_instance.consul.private_ip}"
        TF_SERF_VERSION = "${var.serf_version}"
    }
}

resource "aws_instance" "docker0" {
  ami                    = "${data.aws_ami.server.id}"
  instance_type          = "${var.server_type}"
  key_name               = "${var.key_pair}"
  subnet_id              = "${aws_subnet.demo.id}"
  private_ip             = "${var.docker0_ip}"
  vpc_security_group_ids = [ "${aws_security_group.docker.id}" ]
  user_data              = "${data.template_file.setup_docker0.rendered}"

  tags {
    Name = "Demo Docker0"
  }
}

data "template_file" "setup_docker1" {
    template     = "${file("${path.module}/files/setup_docker.tpl.sh")}"
    vars {
        TF_HOSTNAME = "docker1"
        TF_HOST_IP = "${var.docker1_ip}"
        TF_CONSUL_IP = "${aws_instance.consul.private_ip}"
        TF_SERF_VERSION = "${var.serf_version}"
    }
}

resource "aws_instance" "docker1" {
  ami                    = "${data.aws_ami.server.id}"
  instance_type          = "${var.server_type}"
  key_name               = "${var.key_pair}"
  subnet_id              = "${aws_subnet.demo.id}"
  private_ip             = "${var.docker1_ip}"
  vpc_security_group_ids = [ "${aws_security_group.docker.id}" ]
  user_data              = "${data.template_file.setup_docker1.rendered}"

  tags {
    Name = "Demo Docker1"
  }
}
