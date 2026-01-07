variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID"
}
