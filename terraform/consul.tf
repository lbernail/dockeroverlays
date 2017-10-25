resource "aws_security_group" "consul" {
  name        = "consul-client"
  description = "Client accessing consul"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    security_groups = ["${aws_security_group.docker.id}"]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "Consul Client"
  }
}

resource "aws_instance" "consul" {
  ami                    = "${data.aws_ami.server.id}"
  instance_type          = "${var.server_type}"
  key_name               = "${var.key_pair}"
  subnet_id              = "${aws_subnet.demo.id}"
  private_ip             = "${var.consul_ip}"
  vpc_security_group_ids = [ "${aws_security_group.consul.id}" ]
  user_data              = "${data.template_file.setup_consul.rendered}"

  tags {
    Name = "Demo Consul"
  }
}

data "template_file" "setup_consul" {
  template = "${file("${path.module}/files/setup_consul.tpl.sh")}"

  vars {
    TF_CONSUL_VERSION = "${var.consul_version}"
    TF_HOSTNAME = "consul"
  }
}
