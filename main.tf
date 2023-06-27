resource "aws_launch_template" "main" {
  name = "${var.component}-${var.env}"

#  iam_instance_profile {    # instance need to fetch parameter from parameter store
#    name = "test"
#  }

  image_id = data.aws_ami.ami.id
  instance_market_options {     #spot instance
    market_type = "spot"
  }

  instance_type = var.instance_type


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