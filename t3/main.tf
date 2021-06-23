provider "aws" {}

data "aws_ami" "redhat" {
  owners = ["309956199498"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["RHEL-8.4.0_HVM-*-x86_64-2-*-GP2"]
  }
}

resource "aws_instance" "my_webserver_1" {
  instance_type = "t2.micro"
  ami = data.aws_ami.redhat.id
  vpc_security_group_ids = [aws_security_group.my_webserver_security_group.id]
  key_name = aws_key_pair.kp.key_name

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname web1"
    ]

    connection {
      type     = "ssh"
      user     = "ec2-user"
      host     = "${self.public_ip}"
      private_key = "${tls_private_key.pk_ansible.private_key_pem}"
    }
  }
}

resource "aws_instance" "my_webserver_2" {
  instance_type = "t2.micro"
  ami = data.aws_ami.redhat.id
  vpc_security_group_ids = [aws_security_group.my_webserver_security_group.id]
  key_name = aws_key_pair.kp.key_name

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname web2"
    ]

    connection {
      type     = "ssh"
      user     = "ec2-user"
      host     = "${self.public_ip}"
      private_key = "${tls_private_key.pk_ansible.private_key_pem}"
    }
  }
}

resource "tls_private_key" "pk_ansible" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "kp_ansible"
  public_key = tls_private_key.pk_ansible.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk_ansible.private_key_pem}' > ../ansible-t3.pem"
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