provider "aws" {
  region = "eu-west-3" # Paris
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical (Ubuntu)
}

resource "aws_instance" "devops_app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "devops-key"

  tags = {
    Name = "devops-log-instance"
  }

  provisioner "remote-exec" {
    inline = ["echo Instance created"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/devops-key.pem") # ton chemin de clé privée
      host        = self.public_ip
    }
  }

  #ouvre  port SSH et docker API si besoin
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
}

resource "aws_security_group" "devops_sg" {
  name        = "devops-sg"
  description = "Allow SSH and app access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
