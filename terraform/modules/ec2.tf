###############################################################################
# AMI
###############################################################################
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

###############################################################################
# EC2 instance profile for SSM Session Manager
###############################################################################
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_ssm" {
  name               = "${local.name_prefix}-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "${local.name_prefix}-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm.name

  tags = local.common_tags
}

###############################################################################
# SSH key pair
###############################################################################
resource "tls_private_key" "elk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "elk" {
  key_name   = "${local.name_prefix}-key"
  public_key = tls_private_key.elk.public_key_openssh

  tags = local.common_tags
}

resource "local_sensitive_file" "elk_private_key" {
  content         = tls_private_key.elk.private_key_pem
  filename        = "${path.root}/${local.name_prefix}.pem"
  file_permission = "0600"
}

resource "aws_instance" "elk" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.elk.id]
  key_name               = aws_key_pair.elk.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm.name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-elk"
  })

  lifecycle {
    ignore_changes = [
      ami, # 新しい AL2023 AMI がリリースされても再作成しない
    ]
  }
}

resource "aws_eip" "elk" {
  instance = aws_instance.elk.id
  domain   = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-elk-eip"
  })

  depends_on = [aws_internet_gateway.main]
}
