#efs mount to application server
resource "aws_efs_file_system" "efs_volume" {
  creation_token   = "EFS Shared Data"
  performance_mode = "generalPurpose"
  encrypted        = "true"
  tags = {
    Name = "EFS Shared Data"
  }
}

resource "aws_efs_mount_target" "efs" {
  depends_on      = [aws_efs_file_system.efs_volume, ]
  file_system_id  = aws_efs_file_system.efs_volume.id
  count           = length(var.azs)
  subnet_id       = aws_subnet.private_application[count.index].id
  security_groups = [aws_security_group.ec2_sg.id]
  #   security_groups = "${var.security_groups}"
}

# data "template_file" "script" {
#   template = "file("efs.sh")"
#   vars = {
#     efs_id = "aws_efs_file_system.efs.id"
#   }
# }
resource "aws_efs_access_point" "access-point" {
  file_system_id = aws_efs_file_system.efs_volume.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/access"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0777"
    }
  }
}
#aws_instance.ec2_private_application, 
resource "null_resource" "configure_nfs" {
  depends_on = [aws_efs_access_point.access-point, aws_efs_mount_target.efs]
  count      = length(var.azs)
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.example.private_key_pem
    host        = aws_instance.ec2_private_application_server[count.index].public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install nfs-common -y",
      "sudo apt-get install python3.8 -y",
      "sudo apt-get install python3-pip -y",
      "python --version",
      "python3 --version",
      "echo ${aws_efs_file_system.efs_volume.dns_name}",
      "ls -la",
      "pwd",
      "sudo mkdir -p mount-point",
      "ls -la",
      "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs_volume.dns_name}:/ mount-point",
      "ls",
      "sudo chown -R ubuntu.ubuntu mount-point",
      "cd mount-point",
      "ls",
      "mkdir access",
      "sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1",
      "sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2",
      "printf '2\n' | sudo update-alternatives --config python3",
      "pwd",
      "ls -la",
      "echo 'Python version:'",
      "python3 --version",
      "pip3 install --upgrade --target ./access/ numpy --system"
    ]
  }
}
