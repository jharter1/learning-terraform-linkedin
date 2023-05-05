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

module "blob_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "hartrnet-dev"
  cidr = "10.0.0.0/16"

  azs            = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_instance" "blob" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  subnet_id              = module.blob_vpc.public_subnets[0]
  vpc_security_group_ids = [module.blob_sg.security_group_id]

  tags = {
    Name = "Hello AWS, this is a test"
  }
}

module "blob_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"
  name    = "blob"

  vpc_id              = module.blob_vpc.vpc_id
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}
