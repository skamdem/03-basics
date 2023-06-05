# ordinary resources of aws provider

# Route53 section
data "aws_route53_zone" "my_zone" {
  name = "skamdem.com"
}

resource "aws_route53_record" "devops_subdomain" {
  zone_id = data.aws_route53_zone.my_zone.id
  name    = "devops.${data.aws_route53_zone.my_zone.name}"
  type    = "A"

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}

# Load balancer section
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "set_of_subnet_ids" { # assumed public subnets
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

resource "aws_security_group" "alb_sg" {
  name = "alb-security-group"
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_sg.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_alb_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lb" "load_balancer" {
  name               = "web-app-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.set_of_subnet_ids.ids
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Sorry nothing here -:)"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "custom_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 50

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main_target_group.arn
  }
}

resource "aws_lb_target_group" "main_target_group" {
  name     = "exaample-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200" # response code for healthy responses from a target  
    interval            = 10
    timeout             = 4 # no response -> failed health check
    healthy_threshold   = 2 # consecutive health check successes -> target healthy
    unhealthy_threshold = 2 # consecutive health check failures -> target unhealthy
  }
}

resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.main_target_group.arn
  target_id        = aws_instance.instance_1.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.main_target_group.arn
  target_id        = aws_instance.instance_2.id
  port             = 8080
}


# instances section
# security group for the 2 instances
resource "aws_security_group" "instances_sg" {
  name = "instance-security-group"
}

resource "aws_security_group_rule" "allow_instance_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instances_sg.id
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_instance" "instance_1" {
  ami             = var.instance_ami  # Ubuntu 22.04 LTS
  instance_type   = var.instance_type # "t2.micro"
  security_groups = [aws_security_group.instances_sg.name]
  user_data       = <<-EOF
            #!bin/bash
            echo "Hello from instance ONE" > index.html
            python3 -m http.server 8080 &
            EOF
}

resource "aws_instance" "instance_2" {
  ami             = var.instance_ami  # Ubuntu 22.04 LTS
  instance_type   = var.instance_type # "t2.micro"
  security_groups = [aws_security_group.instances_sg.name]
  user_data       = <<-EOF
            #!bin/bash
            echo "Hello from instance TWO" > index.html
            python3 -m http.server 8080 &
            EOF
}

# s3 bucket section
resource "aws_s3_bucket" "web_app_bucket" {
  bucket_prefix = "devops-web-app-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "web_app_bucket_versionning" {
  bucket = aws_s3_bucket.web_app_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "web_app_bucket_server_side_crypto_conf" {
  bucket = aws_s3_bucket.web_app_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}