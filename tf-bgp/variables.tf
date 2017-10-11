variable "region" { default = "eu-west-1"}
variable "az" { default = "eu-west-1a"}
variable "cidr_block" { default = "10.0.0.0/16"}
variable "overlay_block" { default = "192.168.0.0/16"}
variable "vpc_name" { default = "Demo Docker"}

variable "server_type" { default = "t2.micro"}
variable "key_pair" {}

variable "docker_user" { default = "ubuntu"}
#variable "docker_user" { default = "admin"}
variable "server_ami" {
    type = "map"
    #default = { "basename"= "debian-jessie-amd64-hvm*", "owner"= "379101102735"}
    #default = { "basename"= "debian-stretch-hvm-x86_64-gp2*", "owner"= "379101102735"}
    default = { "basename"= "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64*", "owner"= "099720109477"}
}

variable "bgp_cluster_id" {default = "111.111.111.111"}

variable "quagga_hostnum" { default = "5" }
variable "docker_hostnum" { default = "10" }
variable "gateway_hostnum" { default = "20" }
variable "simple_hostnum" { default = "30" }
variable "quagga_hosts" {default = "2"}
variable "docker_hosts" {default = "2"}
variable "gateway_hosts" {default = "1"}
variable "simple_hosts" {default = "1"}
