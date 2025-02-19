provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region where the EC2 instances will be deployed"
  default     = "ap-south-1"  // Replace with your desired AWS region
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  default     = "ami-05e00961530ae1b55"  // Replace with your desired AMI ID
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  default     = "t2.medium"  // Replace with your desired instance type
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
  description = "Path to the local script file to be copied to the instances"
  default     = "C:/Users/admin/OneDrive/Documents/slave.sh"  // Path to your script on Windows
}

variable "num_slaves" {
  description = "Number of slave instances to create"
  type        = number
  default     = 1 // Default number of instances
}

data "aws_key_pair" "selected" {
  key_name = var.key_pair_name
}

// Create AWS instances using count
resource "aws_instance" "slave_instances" {
  count = var.num_slaves

  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.selected.key_name

  tags = {
    Name = "Slave-${count.index + 1}"  // Naming instances dynamically
  }
}

// Provisioners for setup and execution
resource "null_resource" "setup_slaves" {
  depends_on = [aws_instance.slave_instances]

  count = length(aws_instance.slave_instances)

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install dos2unix -y",  // Install dos2unix
      "sudo mkdir -p /opt",               // Create /opt directory if it doesn't exist
      "sudo chmod 777 /opt"               // Set broad permissions on /opt; adjust as needed
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"         // Replace with appropriate user for your AMI
      private_key = file(var.private_key_path)
      host        = aws_instance.slave_instances[count.index].public_ip  // Access public IP of each instance
    }
  }

  provisioner "file" {
    source      = var.script_path
    destination = "/opt/slave.sh"    // Destination path in the /opt directory

    connection {
      type        = "ssh"
      user        = "ubuntu"         // Replace with appropriate user for your AMI
      private_key = file(var.private_key_path)
      host        = aws_instance.slave_instances[count.index].public_ip  // Access public IP of each instance
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dos2unix /opt/slave.sh",  // Convert slave.sh to Unix format
      "sudo chmod +x /opt/slave.sh", // Set execution permission for slave.sh
               // Execute the script from /opt directory
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"         // Replace with appropriate user for your AMI
      private_key = file(var.private_key_path)
      host        = aws_instance.slave_instances[count.index].public_ip  // Access public IP of each instance
    }
  }
}
