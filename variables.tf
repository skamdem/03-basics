#  variables definition

variable "region" {
  default = "us-east-1"
}

variable "instance_ami" {
  type        = string
  default     = "ami-053b0d53c279acc90" # Ubuntu 22.04 LTS
  description = "ami to use for each of the instances."
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "The type of each of the instances."
}