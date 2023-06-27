data "aws_ami" "ami" {            # refer terraform aws_ami doc
  most_recent      = true
  name_regex       = "devops-practice-with-ansible"   # ami name
  owners           = ["self"]
}