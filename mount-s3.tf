// Creating a S3 Bucket in AWS
resource "aws_s3_bucket" "tfs3bucket" {
  # depends_on = [ null_resource.mount, ]
  bucket = "my-tf-test-bucket"
  acl    = "public-read-write"
}

  module "launch-template_example_s3fs" {
  source  = "figurate/launch-template/aws//examples/s3fs"
  version = "1.0.3"
  iam_instance_profile = aws_iam_instance_profile.some_profile.id
  # buckets = ["hh","my-tf-test-bucket"]
  # image = var.webservers_ami
  # instance_type = var.instance_type
}

# resource "null_resource" "mount" {
#   depends_on = [aws_efs_access_point.access-point, aws_efs_mount_target.mount]
#   connection {
#     type     = "ssh"
#     user     = "ec2-user"
#     private_key = tls_private_key.example.private_key_pem
#     host     = aws_instance.ec2_public.public_ip
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum update",
#       "sudo yum install automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel",
#       "git clone https://github.com/s3fs-fuse/s3fs-fuse.git",
#       "cd s3fs-fuse",
#       "./autogen.sh",
#       "./configure — prefix=/usr — with-openssl",
#       "make",
#       "sudo make install",
#       "which s3fs",
#       "sudo mkdir -p /var/s3fs-demofs",
#       "s3fs -o iam_role=”s3fsmountingrole” -o url=”https://s3-eu-central-1.amazonaws.com" -o endpoint=eu-central-1 -o dbglevel=info -o curldbg -o allow_other -o use_cache=/tmp s3fs-demobucket/var/s3fs-demofs",
#     ]
#   }
# }

# data "template_file" "s3fs" {
#   template = <<EOF
# #!/bin/bash
# sudo amazon-linux-extras install epel
# sudo yum install -y s3fs-fuse
# echo '$${FSMounts}' >> /etc/fstab
# mkdir -p $${MountTargets}
# mount -a
# EOF
#   vars = {
#     MountTargets = join(" ", [for b in var.buckets : b[1]])
#     FSMounts     = join("\n", [for b in var.buckets : "${b[0]} ${b[1]} fuse.s3fs _netdev,allow_other,iam_role=auto 0 0"])
#   }
# }