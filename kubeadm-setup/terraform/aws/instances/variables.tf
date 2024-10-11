variable "ami_id" {
  type    = string
  default = "ami-03f0544597f43a91d"
}

variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-0b9b2c89b4cc0f290", "subnet-094f8e4ea31ec571c","subnet-0dd7a19b1a941dc18"]
}
