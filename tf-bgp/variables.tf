variable "region" { default = "eu-west-1"}
variable "az" { default = "eu-west-1a"}
variable "cidr_block" { default = "10.0.0.0/24"}
variable "vpc_name" { default = "Demo Docker"}

variable "server_type" { default = "t2.micro"}
variable "key_pair" {}

variable "docker_user" { default = "ubuntu"}
variable "server_ami" {
    type = "map"
    #default = { "basename"= "debian-jessie-amd64-hvm*", "owner"= "379101102735"}
    default = { "basename"= "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64*", "owner"= "099720109477"}
}

variable "quagga_ip" { default = "10.0.0.5" }
variable "docker0_ip" { default = "10.0.0.10" }
variable "docker1_ip" { default = "10.0.0.11" }
