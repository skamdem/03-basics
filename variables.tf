#  variables definition

# General variables
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Default region for provider"
}

# EC2 variables
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

# S3 variables
variable "bucket_prefix" {
  type        = string
  description = "The prefix of s3 bucket for app data."
}

# Route 53 variables
variable "domain" {
  type        = string
  description = "Domain for website."
}

variable "subdomain" {
  type        = string
  description = "Subdomain for website."
}
