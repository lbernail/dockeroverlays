output "quagga_public_ips" {
  value = ["${aws_instance.quagga.*.public_ip}"]
}

output "docker_public_ips" {
  value = ["${aws_instance.docker.*.public_ip}"]
}

output "gateway_public_ips" {
  value = ["${aws_instance.gateway.*.public_ip}"]
}

output "simple_public_ips" {
  value = ["${aws_instance.simple.*.public_ip}"]
}
