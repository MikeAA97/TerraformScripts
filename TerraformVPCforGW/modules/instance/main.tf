resource "aws_iam_role" "role" {
  name = "role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
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

  tags = {
    tag-key = "Made by Terraform"
  }
}

resource "aws_iam_role_policy" "policy" {
  name = "policy"
  role = aws_iam_role.role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssmmessages:*",
          "ssm:UpdateInstanceInformation",
          "ec2messages:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_instance_profile" "profile" {
  name = "profile"
  role = aws_iam_role.role.name
}

resource "aws_instance" "web" {

  ami                  = var.ami
  instance_type        = var.instance_type
  availability_zone    = var.availability_zone
  iam_instance_profile = aws_iam_instance_profile.profile.name
  security_groups      = var.security_groups #Check if this is weird
  subnet_id            = var.subnet_id       #Check if this is weird
  user_data            = "#!/bin/bash"


  tags = {
    Name = "Made by Terraform"
  }
  depends_on = [aws_iam_role.role, aws_iam_role_policy.policy]
}

#Is there anything else to configure into a variable?
#names for the different resources? i.e role, profile, policy