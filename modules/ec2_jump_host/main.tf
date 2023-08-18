data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_subnet" "subnet" {
  id = var.subnet_id
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "development" {
  name               = "development_jump_host"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

resource "aws_iam_instance_profile" "development" {
  role = aws_iam_role.development.name
  name = aws_iam_role.development.name
}

resource "aws_iam_role_policy_attachment" "temp" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.development.name
}

resource "aws_security_group" "jump_host_sg" {
  name   = "jump_host_sg"
  vpc_id = data.aws_subnet.subnet.vpc_id
}

resource "aws_security_group_rule" "jump_host_sg_outbound" {
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  security_group_id = aws_security_group.jump_host_sg.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                   = "development_jump_host"
  iam_instance_profile   = aws_iam_instance_profile.development.id
  ami                    = data.aws_ami.amazon_linux_2.image_id
  instance_type          = "t2.small"
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.jump_host_sg.id]
  subnet_id              = var.subnet_id
}
