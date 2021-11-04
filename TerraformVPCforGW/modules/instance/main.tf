resource "aws_instance" "web" {

  ami                  = var.ami
  instance_type        = var.instance_type
  availability_zone    = var.availability_zone
  #iam_instance_profile = aws_iam_instance_profile.profile.name
  iam_instance_profile = var.instance_profile
  security_groups      = var.security_groups
  subnet_id            = var.subnet_id
  user_data            = "#!/bin/bash"


  tags = {
    Name = "Made by Terraform"
  }
  depends_on = [aws_iam_role.role, aws_iam_role_policy.policy]
}

#Is there anything else to configure into a variable?
#names for the different resources? i.e role, profile, policy