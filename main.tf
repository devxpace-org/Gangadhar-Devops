provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "exampletf" {
  ami                    = "ami-0f3769c8d8429942f"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.exampletf.id]
}


resource "aws_security_group" "exampletf" {
  name        = "exampletf"
  description = "Example security group for EC2"

  # Define ingress rules (allow incoming traffic)
  ingress {
    from_port   = 22 # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80 # HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443 # HTTPS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ebs_volume" "ebs_volume" {
    availability_zone = "us-west-2a" 
    size             = 1           
}
  
resource "aws_volume_attachment" "volume_attachment" {
    device_name = "/dev/sdf"                         
    instance_id = aws_instance.exampletf.id              
    volume_id   = aws_ebs_volume.ebs_volume.id    
}


resource "aws_s3_bucket" "terraformgs3" {
  bucket = "s3tfgbucket"
  
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = "s3-read-policy"
  description = "Allows read access to a specific S3 object"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::s3tfgbucket/gangafile",
      },
    ],
  })
}

resource "aws_iam_role" "example_role" {
  name = "GangadharRole1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "example_policy_attachment" {
  name       = "instanceec2_policy_attachment"
  policy_arn = aws_iam_policy.s3_read_policy.arn
  roles      = [aws_iam_role.example_role.name]
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile1"
  role = aws_iam_role.example_role.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


output "publicip" {
  value = aws_instance.exampletf.public_ip
}

output "privateip" {
  value = aws_instance.exampletf.private_ip
}

