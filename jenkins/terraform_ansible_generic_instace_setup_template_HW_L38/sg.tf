resource "random_pet" "sg" {}
locals {
  allowed_ingress_ports = [22, 80, 443]
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"

dynamic "ingress" {
    for_each = local.allowed_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
ingress {
    protocol    = "ICMP"               #ICMP from my local PC
    cidr_blocks = ["172.89.184.11/32"]
  }
egress {
    from_port   = 0
    to_port     = 65000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}