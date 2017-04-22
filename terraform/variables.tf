variable "region" { default = "eu-west-1"}
variable "az" { default = "eu-west-1a"}
variable "cidr_block" { default = "10.0.0.0/24"}
variable "vpc_name" { default = "Demo Docker"}

variable "server_type" { default = "t2.micro"}
variable "key_pair" {}

variable "consul_version" { default = "0.8.1" }
variable "consul_ip" { default = "10.0.0.5" }
variable "docker0_ip" { default = "10.0.0.10" }
variable "docker1_ip" { default = "10.0.0.11" }
