output "quagga_public_ip" {
  value = ["${aws_instance.quagga.public_ip}"]
}

output "docker0_public_ip" {
  value = ["${aws_instance.docker0.public_ip}"]
}

output "docker1_public_ip" {
  value = ["${aws_instance.docker1.public_ip}"]
}
