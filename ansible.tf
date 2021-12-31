resource "aws_instance" "ansible_master_node" {
  ami                         = "ami-0ed9277fb7eb570c9"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.generated_key.key_name

  subnet_id              = aws_subnet.public_web[0].id
  iam_instance_profile   = aws_iam_instance_profile.admin_profile.id
  user_data              = file("user-data-ansible-engine.sh")
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  provisioner "remote-exec" {
    inline = [
      "echo '[ansible]' >> /home/ec2-user/inventory",
      "echo 'ansible-engine ansible_host=${aws_instance.ansible_master_node.private_dns} ansible_connection=local' >> /home/ec2-user/inventory",
      "echo '[nodes]' >> /home/ec2-user/inventory",
      "echo 'node1 ansible_host=${aws_instance.ec2_public[0].private_dns}' >> /home/ec2-user/inventory",
      "echo 'node2 ansible_host=${aws_instance.ec2_public[1].private_dns}' >> /home/ec2-user/inventory",
      "echo 'node3 ansible_host=${aws_instance.ec2_private_application_server[0].private_dns}' >> /home/ec2-user/inventory",
      "echo 'node4 ansible_host=${aws_instance.ec2_private_application_server[1].private_dns}' >> /home/ec2-user/inventory",
      "echo 'node5 ansible_host=${aws_instance.ec2_private_dbms_server[0].private_dns}' >> /home/ec2-user/inventory",
      "echo 'node6 ansible_host=${aws_instance.ec2_private_dbms_server[1].private_dns}' >> /home/ec2-user/inventory",
      "echo 'node7 ansible_host=${aws_instance.ec2_main_public.private_dns}' >> /home/ec2-user/inventory",
      "echo '' >> /home/ec2-user/inventory",
      "echo '[all:vars]' >> /home/ec2-user/inventory",
      "echo 'ansible_user=etiya' >> /home/ec2-user/inventory",
      "echo 'ansible_password=etiya' >> /home/ec2-user/inventory",
      "echo 'ansible_connection=ssh' >> /home/ec2-user/inventory",
      "echo '#ansible_python_interpreter=/usr/bin/python3' >> /home/ec2-user/inventory",
      "echo 'ansible_ssh_private_key_file=/home/devops/.ssh/id_rsa' >> /home/ec2-user/inventory",
      "echo \"ansible_ssh_extra_args=' -o StrictHostKeyChecking=no -o PreferredAuthentications=password '\" >> /home/ec2-user/inventory",
      "echo '[defaults]' >> /home/ec2-user/ansible.cfg",
      "echo 'inventory = ./inventory' >> /home/ec2-user/ansible.cfg",
      "echo 'host_key_checking = False' >> /home/ec2-user/ansible.cfg",
      "echo 'remote_user = devops' >> /home/ec2-user/ansible.cfg",
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.example.private_key_pem
      host        = self.public_ip
    }
  }

    # copy engine-config.yaml
    provisioner "file" {
      source      = "engine-config.yaml"
      destination = "/home/ec2-user/engine-config.yaml"
      connection {
        type = "ssh"
        user = "ec2-user"
        private_key = tls_private_key.example.private_key_pem      
        host = self.public_ip
      }
    }

  # Execute Ansible Playbook
  provisioner "remote-exec" {
    inline = [
      "sleep 120; ansible-playbook engine-config.yaml"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.example.private_key_pem
      host        = self.public_ip
    }
  }

  tags = {
    Name = "ansible-engine"
  }
}

# resource "null_resource" "ansible" {
#   depends_on = []
#   connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = tls_private_key.example.private_key_pem
#     host        = aws_instance.ansible_master_node.public_ip
#   }
#   # Create inventory and ansible.cfg on ansible-engine
# }

output "ec2_public" {
  //count = length(var.azs)
  value = aws_instance.ec2_public.*.public_ip
}

output "ec2_private_application_server" {
  //count = length(var.azs)
  value = aws_instance.ec2_private_application_server.*.public_ip
}

output "ec2_private_dbms_server" {
  //count = length(var.azs)
  value = aws_instance.ec2_private_dbms_server.*.public_ip
}

output "ec2_main_public" {
  //count = length(var.azs)
  value = aws_instance.ec2_main_public.*.public_ip
}