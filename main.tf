resource "aws_launch_template" "main" {
  name = "${var.component}-${var.env}"

  iam_instance_profile {    # instance need to fetch parameter from parameter store
    name = aws_iam_instance_profile.main.name
  }

  image_id = data.aws_ami.ami.id
  instance_market_options {     #spot instance
    market_type = "spot"
  }

  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]


  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      { Name = "${var.component}-${var.env}" }
    )
  }

    #user_data = filebase64("${path.module}/userdata.sh")  #path.module : inside a module
    user_data = base64encode(templatefile("${path.module}/userdata.sh", {   ## when instance created automatically ansible kickoff
    component = var.component
    env   = var.env
  } ))
}

## launch template versions
resource "aws_autoscaling_group" "main" {
  name = "${var.component}-${var.env}"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.subnets                # subnet
  target_group_arns   = [aws_lb_target_group.main.arn]

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
 tag {
   key                 = "name"
   propagate_at_launch = false
   value               = "${var.component}-${var.env}"
 }
}

## vpc security group creation
resource "aws_security_group" "main" {
  name        = "${var.component}-${var.env}"
  description = "${var.component}-${var.env}"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      =  var.bastion_cidr   # to whom have to allow , ssh bastion entry in env-dev
  }

  ingress {
    description      = "APP"
    from_port        = var.port
    to_port          = var.port
    protocol         = "tcp"
    cidr_blocks      = var.allow_app_to
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    var.tags,
    { Name = "${var.component}-${var.env}" }
  )
}

# create target group
resource "aws_lb_target_group" "main" {  # attach this TG to auto scaling
  name     = "${var.component}-${var.env}"
  port     = var.port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled = true
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 5
    timeout = 4
  }
  tags = merge(
    var.tags,
    { Name = "${var.component}-${var.env}" }
  )
}

# CNAME
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = local.dns_name
  type    = "CNAME"
  ttl     = 30
  records = [var.alb_dns_name]
}