terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.5"
          }
  }
  backend "s3" {
    bucket    = "terraform-state-test-my-cloud-aleks"
    key       = "terraform_my_infra_ahm.tfstate"
    region    = "us-east-1"
  }
  required_version = ">= 1.3"
}
provider "aws" {
  region     = "us-east-1"
}

#resource "tls_private_key" "test_key" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}
#
#resource "aws_key_pair" "generated_key" {
#  key_name   = "test_key"
#  public_key = tls_private_key.test_key.public_key_openssh
#}

resource "random_pet" "sg" {}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 65000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Creating policy and role for adding Route 53 A-Record to EC2 

# Create IAM Policy
# resource "aws_iam_policy" "route53_update_policy" {
#   name   = "Route53UpdatePolicy"
#   path   = "/"
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect   = "Allow",
#         Action   = [
#           "route53:ChangeResourceRecordSets",
#           "route53:ListHostedZones",
#           "route53:GetChange"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# Create IAM Role для EC2
# resource "aws_iam_role" "route53_update_role" {
#   name = "Route53UpdateRole"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# Attach Policy к Role
# resource "aws_iam_role_policy_attachment" "route53_update_attach" {
#   role       = aws_iam_role.route53_update_role.name
#   policy_arn = aws_iam_policy.route53_update_policy.arn
# }

#Define the Role! (eliminated after terraform destroy!)
resource "aws_iam_role" "route53_update_role" {
  name = "Route53UpdateRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

#Point your existing IAM policy!
data "aws_iam_policy" "route53_update_policy" {
  arn = "arn:aws:iam::624586740279:policy/Route53UpdatePolicy"
}

#Attach the policy to the role!
resource "aws_iam_role_policy_attachment" "route53_update_attach" {
  role       = aws_iam_role.route53_update_role.name
  policy_arn = data.aws_iam_policy.route53_update_policy.arn
}

# Create Instance Profile
resource "aws_iam_instance_profile" "route53_update_profile" {
  name = "Route53UpdateProfile"
  role = aws_iam_role.route53_update_role.name
}

# Пример EC2 с этой ролью
#resource "aws_instance" "my_instance" {
#  ami           = "ami-053b0d53c279acc90" # Подставь свой AMI ID
#  instance_type = "t2.micro"
#
#  iam_instance_profile = aws_iam_instance_profile.route53_update_profile.name
#
#  tags = {
#    Name = "EC2-With-Route53-Role"
#  }
#}

resource "aws_instance" "test" {
  ami                    = "ami-0ecb62995f68bb549" // Ubuntu server 24.04 LTS
  instance_type          = "t2.micro" //instance type
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.route53_update_profile.name
  key_name               = "key-homework-lab-server" //new key
    tags = {
    Name = "alex-tech.us_TF_MyWebSite_Gallery"
  }
}

output "web-address_test_instance_public_dns" {
  value = aws_instance.test.public_dns
}

output "web-address_test_instance_public_ip" {
  value = aws_instance.test.public_ip
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

#resource "terraform_data" "generate_inventory" {
#  depends_on = [aws_instance.test]
#
#provisioner "local-exec" {
#  command = "./generate_inventory_with_clean.sh"
#  interpreter = ["/bin/bash", "-c"]
#}
#}