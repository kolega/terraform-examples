provider "aws" {}

resource "aws_instance" "my_webserver" {
  instance_type = "t2.micro"
  ami = "ami-0b0af3577fe5e3532"
  vpc_security_group_ids = [aws_security_group.my_webserver_security_group.id]
  key_name = aws_key_pair.kp.key_name
  user_data = <<EOF
#!/bin/bash
yum -y update
yum -y install httpd
echo "My first AWS infrastruce from terraform!!!" > /var/www/html/index.html
service httpd start
chkconfig httpd on
EOF
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ../webserver-t2.pem"
  }
}

resource "aws_security_group" "my_webserver_security_group" {
  name        = "My Webserver Security Group"
  description = "My first security group"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}