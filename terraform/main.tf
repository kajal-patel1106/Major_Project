provider "aws" {
  region = "ap-south-1"
}

# Create Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "devops-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Security Group
resource "aws_security_group" "ubuntu_sg" {
  name        = "ubuntu-security-group"
  description = "Allow SSH, Jenkins, SonarQube, App Access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SonarQube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes NodePort"
    from_port   = 30000
    to_port     = 32767
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

# Ubuntu EC2 Instance
resource "aws_instance" "ubuntu_server" {
  ami                    = "ami-07a00cf47dbbc844c" # Ubuntu 22.04 ap-south-1
  instance_type          = "c7i-flex.large"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.ubuntu_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "DevOps-Server"
  }
}

# Output Public IP
output "public_ip" {
  value = aws_instance.ubuntu_server.public_ip
}