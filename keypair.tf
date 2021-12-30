resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "generated_key" {
  key_name   = "my_tf_key_name"
  public_key = tls_private_key.example.public_key_openssh
}

resource "null_resource" "save_key_pair"  {
provisioner "local-exec" {
command = "echo  ${tls_private_key.example.private_key_pem} > mykey.pem"
}

}