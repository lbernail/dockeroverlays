data "aws_ami" "server" {
  most_recent = true
  filter {
    name = "name"
    values = ["${var.server_ami["basename"]}"]
  }
  owners = ["${var.server_ami["owner"]}"]
}
