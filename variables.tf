#  variables definition

# General variables
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Default region for provider"
}

# ALB variables
variable "alb_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
    description = string
  }))
  default = [
    { from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "ordinary request"
    },
    { from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "encrypted request"
    },
  ]
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
