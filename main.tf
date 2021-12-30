terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.70.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  #   profile = "abdullah"
}


#Encrypt EC2 instance with KMS key
resource "aws_kms_key" "a" {
  description              = "My Ec2 KMS key"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
}


// Configure the EC2 instance in a public subnet
resource "aws_instance" "ec2_public" {
  ami                         = "ami-0ed9277fb7eb570c9"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.generated_key.key_name
  count                       = length(var.azs)
  subnet_id                   = aws_subnet.public_web[count.index].id
  #   vpc_security_group_ids      = [var.sg_pub_id]

  # root disk
  root_block_device {
    volume_size           = "5"
    volume_type           = "gp2"
    encrypted             = true
    kms_key_id            = aws_kms_key.a.key_id
    delete_on_termination = true
  }
  # data disk
  ebs_block_device {
    device_name           = "/dev/xvda" #required
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = true
    kms_key_id            = aws_kms_key.a.key_id
    delete_on_termination = true
  }

  tags = {
    "Name" = "${var.namespace}-EC2-PUBLIC"
  }

}



// Configure the EC2 instance in a private subnet
resource "aws_instance" "ec2_private_application_server" {
  ami                         = "ami-0ed9277fb7eb570c9"
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.generated_key.key_name
  count                       = length(var.azs)
  subnet_id                   = aws_subnet.private_application[count.index].id
  #   user_data = "data.template_file.script"

  #   vpc_security_group_ids      = [var.sg_priv_id]
  # root disk
  root_block_device {
    volume_size           = "5"
    volume_type           = "gp2"
    encrypted             = true
    kms_key_id            = aws_kms_key.a.key_id
    delete_on_termination = true
  }
  # data disk
  ebs_block_device {
    device_name           = "/dev/xvda" #required
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = true
    kms_key_id            = aws_kms_key.a.key_id
    delete_on_termination = true
  }

  tags = {
    "Name" = "${var.namespace}-EC2-PRIVATE"
  }

}


resource "aws_instance" "ec2_private_dbms_server" {
  ami                         = "ami-0ed9277fb7eb570c9"
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.generated_key.key_name
  count                       = length(var.azs)
  subnet_id                   = aws_subnet.private_dbms[count.index].id

  # root disk
  root_block_device {
    volume_size           = "5"
    volume_type           = "gp2"
    encrypted             = true
    kms_key_id            = aws_kms_key.a.key_id
    delete_on_termination = true
  }
  # data disk
  ebs_block_device {
    device_name           = "/dev/sdh" #required
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = true
    kms_key_id            = aws_kms_key.a.key_id
    delete_on_termination = true
  }

  tags = {
    "Name" = "${var.namespace}-EC2-PRIVATE2"
  }

}
#   vpc_security_group_ids      = [var.sg_priv_id]


#  "AWS": "arn:aws:iam::066944718821:root"



resource "aws_vpc_endpoint" "gateway_services" {
  vpc_id       = aws_vpc.my_vpc.id
  service_name = "com.amazonaws.${var.aws_region}"
  #   subnet_ids        = ["${var.private_subnet1}", "${var.private_subnet2}"]
  #   vpc_endpoint_type = "Interface"

  #   security_group_ids = ["${var.security_group}",]
}

# associate route table with VPC endpoint
resource "aws_vpc_endpoint_route_table_association" "Private_route_table_association" {
  count = length(var.azs)
  #   route_table_id  = element(aws_route_table.application.*.id, count.index)
  route_table_id  = aws_route_table.private[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.gateway_services.id
}


resource "aws_instance" "ec2_main_public" {
  ami                         = "ami-0ed9277fb7eb570c9"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.generated_key.key_name

  subnet_id = aws_subnet.public_web[0].id
  #   vpc_security_group_ids      = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]
}

resource "aws_instance" "ansible_master_node" {
  ami                         = "ami-0ed9277fb7eb570c9"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.generated_key.key_name

  subnet_id            = aws_subnet.public_web[0].id
  iam_instance_profile = aws_iam_instance_profile.admin_profile.id
  #   vpc_security_group_ids      = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]
}