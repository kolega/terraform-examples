output "web1_ip_addr" {
  value = aws_instance.my_webserver_1.public_ip
}

output "web2_ip_addr" {
  value = aws_instance.my_webserver_2.public_ip
}