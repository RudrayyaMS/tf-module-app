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

// user_data = filebase64("${path.module}/example.sh")
}