# list of providers

provider "aws" {
  region = var.region
}

# Module to create and validate the AWS certificate
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.3.2"

  domain_name = var.domain
  zone_id     = local.zone_id

  subject_alternative_names = [
    "*.${var.domain}",
    "${var.subdomain}.${var.domain}",
  ]

  wait_for_validation = true

  tags = {
    Name = "${var.domain}"
  }
}