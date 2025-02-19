provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region where the EC2 instance will be deployed"
  default     = "ap-south-1"  // Replace with your desired AWS region
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-05e00961530ae1b55"  // Replace with your desired AMI ID
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  default     = "t3.xlarge"  // Replace with your desired instance type
}

variable "key_pair_name" {
  description = "Name of the SSH key pair to use for instance access"
  default     = "mum"  // Replace with your actual key pair name
}

variable "private_key_path" {
  description = "Path to the private key file on your local machine"
  default     = "C:/Users/admin/Downloads/keypairs/mum.pem"  // Replace with your actual private key path
}

variable "script_path" {
  description = "Path to the local script file to be copied to the instance"
  default     = "C:/Users/admin/OneDrive/Documents/master.sh"  // Path to your script on Windows
}

data "aws_key_pair" "selected" {
  key_name = var.key_pair_name
}

resource "aws_instance" "main_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.selected.key_name

  tags = {
    Name = "Ubuntu-22"
  }

  // Set permissions on /opt directory to allow writing files
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /opt"  // Set broad permissions on /opt; adjust as needed
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"  // Replace with appropriate user for your AMI
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  // Install dos2unix
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y dos2unix"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  // Copy the file to /opt directory
  provisioner "file" {
    source      = var.script_path
    destination = "/opt/master.sh"  // Destination path in the /opt directory

    connection {
      type        = "ssh"
      user        = "ubuntu"  // Replace with appropriate user for your AMI
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  // Set executable permissions on the copied script
  provisioner "remote-exec" {
    inline = [

      "dos2unix /opt/master.sh" ,
      "sudo chmod +x /opt/master.sh"  // Set execution permission for master.sh
                                         // Convert script to Unix format
                                          // Execute the script
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"  // Replace with appropriate user for your AMI
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  // Connect using SSH after setup
  connection {
    type        = "ssh"
    user        = "ubuntu"  // Replace with appropriate user for your AMI
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }
}
