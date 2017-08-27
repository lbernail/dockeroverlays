resource "aws_security_group" "quagga" {
  name        = "quagga-client"
  description = "Client accessing quagga"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }



  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "Quagga"
  }
}

resource "aws_instance" "quagga" {
  ami                    = "${data.aws_ami.server.id}"
  instance_type          = "${var.server_type}"
  key_name               = "${var.key_pair}"
  subnet_id              = "${aws_subnet.demo.id}"
  private_ip             = "${var.quagga_ip}"
  vpc_security_group_ids = [ "${aws_security_group.quagga.id}" ]
  user_data              = "${data.template_file.setup_quagga.rendered}"

  tags {
    Name = "Demo Quagga"
  }
}

data "template_file" "setup_quagga" {
  template = "${file("${path.module}/files/setup_quagga.tpl.sh")}"

  vars {
    TF_HOSTNAME = "quagga"
    TF_USER = "${var.docker_user}"
    TF_HOST_IP = "${var.quagga_ip}"
  }
}
