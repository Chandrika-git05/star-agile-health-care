provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "kubernetes-server" {
  ami           = "ami-0bbdd8c17ed981ef9"                # Replace with valid AMI ID (e.g., Ubuntu)
  instance_type = "t3.medium"
  vpc_security_group_ids = ["sg-03096b78ac0135593"]     # Replace with valid security group ID(s)
  key_name      = "chandrikakey"

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = "kubernetes-server"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install docker.io -y",
      "sudo systemctl start docker",

      # Install Minikube
      "wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64",
      "chmod +x minikube-linux-amd64",
      "sudo cp minikube-linux-amd64 /usr/local/bin/minikube",

      # Install kubectl
      "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl",
      "chmod +x kubectl",
      "sudo cp kubectl /usr/local/bin/kubectl",

      # Add ubuntu user to docker group
      "sudo groupadd docker || true",   # only create if it doesn't exist
      "sudo usermod -aG docker ubuntu"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("${path.module}/chandrikakey")
   # Path to your private key file
    }
  }
}
