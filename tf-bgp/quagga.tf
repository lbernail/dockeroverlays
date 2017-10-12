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
  count = "${var.quagga_hosts}"
  ami                    = "${data.aws_ami.server.id}"
  instance_type          = "${var.server_type}"
  key_name               = "${var.key_pair}"
  subnet_id              = "${aws_subnet.demo.*.id[count.index]}"
  private_ip             = "${cidrhost(aws_subnet.demo.*.cidr_block[count.index],var.quagga_hostnum)}"
  vpc_security_group_ids = [ "${aws_security_group.quagga.id}" ]
  user_data              = "${data.template_file.setup_quagga.*.rendered[count.index]}"

  tags {
    Name = "Demo Route Reflector ${count.index}"
  }
}

data "template_file" "setup_quagga" {
  count = "${var.quagga_hosts}"
  template = "${file("${path.module}/files/setup_host.tpl.sh")}"

  vars {
    TF_HOSTNAME = "quagga${count.index}"
    TF_USER = "${var.docker_user}"
    TF_HOST_IP = "${cidrhost(aws_subnet.demo.*.cidr_block[count.index],var.quagga_hostnum)}"
    TF_QUAGGA_VERSION = "${var.quagga_version}"
    TF_QUAGGA_CONF = "${data.template_file.conf_quagga_rr.*.rendered[count.index]}"
    TF_QUAGGA_NET = "bridge"
    TF_PULL_IMAGES = "cumulusnetworks/quagga:${var.quagga_version}"
    TF_START_QUAGGA = "yes"
  }
}

data "template_file" "conf_quagga_rr" {
  count = "${var.quagga_hosts}"
  template = "${file("${path.module}/files/quagga-rr.tpl")}"

  vars {
    TF_VPC_CIDR = "${var.cidr_block}"
    TF_HOST_IP = "${cidrhost(aws_subnet.demo.*.cidr_block[count.index],var.quagga_hostnum)}"
    TF_CLUSTER_ID = "${var.bgp_cluster_id}"
  }
}
