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
  ingress {
    from_port   = 8  # This is the ICMP Type, not a port
    to_port     = 0  # This is the ICMP Code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 65000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 1. Update the Role to include S3 Access alongside Route53
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

# 2. Keep your Route53 Policy Attachment
data "aws_iam_policy" "route53_update_policy" {
  arn = "arn:aws:iam::624586740279:policy/Route53UpdatePolicy"
}

resource "aws_iam_role_policy_attachment" "route53_update_attach" {
  role       = aws_iam_role.route53_update_role.name
  policy_arn = data.aws_iam_policy.route53_update_policy.arn
}

# 3. NEW: Add S3 Gallery Permissions to the SAME Role
resource "aws_iam_role_policy" "s3_gallery_access" {
  name = "S3GalleryAccessPolicy"
  role = aws_iam_role.route53_update_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::alex-tech.us-gallery",
          "arn:aws:s3:::alex-tech.us-gallery/*"
        ]
      }
    ]
  })
}

# 4. Create Instance Profile (Using the role that now has BOTH Route53 and S3)
resource "aws_iam_instance_profile" "route53_update_profile" {
  name = "Route53UpdateProfile"
  role = aws_iam_role.route53_update_role.name
}

# 5. S3 Bucket Policy (Allows the Role to talk to the Bucket)
resource "aws_s3_bucket_policy" "allow_access_from_ec2" {
  bucket = "alex-tech.us-gallery"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowRoleAccess"
        Effect    = "Allow"
        Principal = {
          AWS = "${aws_iam_role.route53_update_role.arn}"
        }
        Action    = "s3:*"
        Resource  = [
          "arn:aws:s3:::alex-tech.us-gallery",
          "arn:aws:s3:::alex-tech.us-gallery/*"
        ]
      }
    ]
  })
}

# # Connect NGINX to S3 Bucket:
# # 1. Define the Policy Rules (The Logic)
# data "aws_iam_policy_document" "nginx_s3_access" {
#   statement {
#     sid       = "AllowNginxAccess"
#     effect    = "Allow"
#     actions   = ["s3:GetObject"]
    
#     # My specific bucket ARN
#     resources = ["arn:aws:s3:::alex-tech.us-gallery/*"]

#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#     condition {
#       test     = "IpAddress"
#       variable = "aws:SourceIp"
      
#       # ⚠️ IMPORTANT: Choose ONE of the options below for the 'values' line:
      
#       # OPTION A: If you created the EC2 in this same Terraform project:
#       values = ["${aws_instance.web_server.public_ip}/32"]
      
#       # OPTION B: If your EC2 is already running (created via Ansible/Console):
#       # Replace 1.2.3.4 with your real Public IP
#       # values   = ["1.2.3.4/32"] 
#     }
#   }
# }
# # 2. Attach the Policy to the Bucket (The Action)
# resource "aws_s3_bucket_policy" "allow_access_from_ec2" {
#   # Your specific bucket name (no 'arn:aws:s3:::' prefix here)
#   bucket = "alex-tech.us-gallery"
  
#   # References the logic defined above
#   policy = data.aws_iam_policy_document.nginx_s3_access.json
# }

resource "aws_instance" "web_server" {
  ami                    = "ami-0ecb62995f68bb549" // Ubuntu server 24.04 LTS
  instance_type          = "t2.micro" //instance type
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.route53_update_profile.name
  key_name               = "key-homework-lab-server" //new key
    tags = {
    Name = "alex-tech.us_TF_MyWebSite_Gallery"
    }
}

# Request a new Elastic IP (changes after EC2 rebuilding!)
resource "aws_eip" "my_static_ip" {
  domain = "vpc"
}

# Associate the IP with the Instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web_server.id
  allocation_id = aws_eip.my_static_ip.id
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

# Output the IP address to your EC2
output "public_ip" {
  value = aws_eip.my_static_ip.public_ip
}

#resource "terraform_data" "generate_inventory" {
#  depends_on = [aws_instance.test]
#
#provisioner "local-exec" {
#  command = "./generate_inventory_with_clean.sh"
#  interpreter = ["/bin/bash", "-c"]
#}
#}