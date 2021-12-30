variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "172.31.16.0/21"
}

variable "vpc_name" {
  default = "my--vpc"
}
variable "public_subnets_cidrs" {
  default = ["172.31.16.0/24", "172.31.17.0/24"]
}

variable "private_subnets_cidrs" {
  default = ["172.31.18.0/24", "172.31.19.0/24"]
}

variable "private_subnets_cidrs2" {
  default = ["172.31.20.0/24", "172.31.21.0/24"]
}

variable "azs" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "webservers_ami" {
  default = "ami-0ed9277fb7eb570c9"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "namespace" {
  default = "dev_to_prod"
}


variable "project" {
  default = "etiya_terraform"

}

# variable "buckets" {
#   description = "List of S3 bucket to mount"
#   type        = list(tuple([string, string]))
#   default     = list(tuple(["my-tf-test-bucketf"]))
# }

# variable "profile" {}
# variable "public_key" {}
# variable "attach_public_ip" {
#   type = bool
# }

# variable "tags" {
#   Name    = "VPC"
#   Team    = "DevOps"
#   Billing = "CFO"
#   Quarter = "3"
#   AppName = "WebServer"
# }