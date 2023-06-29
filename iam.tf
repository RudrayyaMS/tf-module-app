# policy creation
resource "aws_iam_policy" "policy" {
  name        = "${var.component}-${var.env}"
  path        = "/"
  description = "${var.component}-${var.env}"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource": "arn:aws:ssm:us-east-1:${data.aws_caller_identity.account.account_id}:parameter/${var.env}.${var.component}*"
      },
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": "ssm:DescribeParameters",
        "Resource": "*"
      }
    ]
  })
}

# create a role
resource "aws_iam_role" "main" {
  name = "${var.component}-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.tags,
    { Name = "${var.component}-${var.env}" }
  )
}

# instance profile
resource "aws_iam_instance_profile" "main" {
  name = "${var.component}-${var.env}"
  role = aws_iam_role.main.name
}

# attach this policy to role
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}