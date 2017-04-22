variable "server_ami" {
    type = "map"
    default = { "basename"= "debian-jessie-amd64-hvm*", "owner"= "379101102735"}
}

data "aws_ami" "server" {
  most_recent = true
  filter {
    name = "name"
    values = ["${var.server_ami["basename"]}"]
  }
  owners = ["${var.server_ami["owner"]}"]
}
