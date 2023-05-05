data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "blob" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids =[module.blob-sg.security_group_id]

  tags = {
    Name = "HelloWorld"
  }
}

module "blob-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.2"
  name = "blob_new_security_group"

  vpc_id = data.aws_vpc.default.id
  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "blob" {
  name        = "blob"
  description = "Allow https & http inwards; everything outwards"

  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "blob_http_in" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blob.id
}

resource "aws_security_group_rule" "blob_https_in" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blob.id
}

resource "aws_security_group_rule" "blob_all_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blob.id
}