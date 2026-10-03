data "aws_ami" "nixos_arm64" {
  owners      = ["427812963091"]
  most_recent = true

  filter {
    name   = "name"
    values = ["nixos/26.05*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_key_pair" "root" {
  key_name   = "tarkin-root"
  public_key = var.ssh_public_key
  tags       = { Name = "tarkin-root" }
}

resource "aws_iam_role" "host" {
  name = "tarkin-ec2-host"
  tags = { Name = "tarkin-ec2-host" }
  assume_role_policy = jsonencode(
    {
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
    }
  )

}

resource "aws_iam_role_policy" "host_runtime" {
  name = "tarkin-host-runtime"
  role = aws_iam_role.host.id
  policy = jsonencode({
    Version = "2012-10-17", Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = aws_secretsmanager_secret.age.arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "host" {
  name = "tarkin-ec2-host"
  role = aws_iam_role.host.name
  tags = { Name = "tarkin-ec2-host" }
}

resource "aws_secretsmanager_secret" "age" {
  name                    = "tarkin-age-identity"
  description             = "Manually injected Tarkin host Age identity; Terraform never manages a version"
  recovery_window_in_days = 30
  tags                    = { Name = "tarkin-age-identity" }
}

resource "aws_instance" "nixos_arm64" {
  count                       = var.create_instance ? 1 : 0
  ami                         = data.aws_ami.nixos_arm64.id
  instance_type               = "t4g.small"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.lighthouse.id]
  associate_public_ip_address = false
  lifecycle {
    ignore_changes = [associate_public_ip_address]
  }
  key_name             = aws_key_pair.root.key_name
  iam_instance_profile = aws_iam_instance_profile.host.name
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }
  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    delete_on_termination = true
    volume_size           = 8
  }
  depends_on = [aws_internet_gateway.tarkin]
}

resource "aws_eip_association" "tarkin" {
  count         = var.create_instance ? 1 : 0
  instance_id   = aws_instance.nixos_arm64[0].id
  allocation_id = aws_eip.tarkin.id
}
