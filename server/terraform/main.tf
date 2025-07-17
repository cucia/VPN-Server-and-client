provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "vpn_server" {
  ami                    = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 LTS in us-east-1
  instance_type          = "t2.micro"
  key_name               = "hydra"
  vpc_security_group_ids = [aws_security_group.vpn_sg.id]
  user_data              = file("${path.module}/setup-wireguard.sh")

  tags = {
    Name = "CredGuard-VPN-Server"
  }
}

resource "aws_security_group" "vpn_sg" {
  name        = "vpn-security-group"
  description = "Allow SSH, API, and WireGuard"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
