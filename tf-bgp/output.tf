output "quagga_public_ips" {
  value = ["${aws_instance.quagga.*.public_ip}"]
}

output "docker_public_ips" {
  value = ["${aws_instance.docker.*.public_ip}"]
}
