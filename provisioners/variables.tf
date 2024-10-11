variable "aws_region" {
  description = "AWS region to deploy instances"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for instances"
  default     = "ami-0b8aeb1889f1a812a"
}

variable "instance_type_main" {
  description = "Instance type for the main instance"
  default     = "t3.xlarge"
}

variable "instance_type_secondary" {
  description = "Instance type for the secondary instances"
  default     = "t2.medium"
}

variable "instance_count" {
  description = "Number of secondary instances"
  default     = 3
}
