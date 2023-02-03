variable "aws_region" {
  description = "Preferred region in which to launch EC2 instances. Defaults to us-east-1"
  type        = string
  default     = "us-east-1"
}

variable "nameprefix" {
  description = "Prefix to use for some resource names to avoid duplicates"
  type        = string
  default     = "Cloud-AWS-Apache-Terraform"
}

variable "name_tag" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "Cloud-AWS-Apache-Terraform"
}

variable "project_tag" {
  description = "Value of the Project tag for the EC2 instance"
  type        = string
  default     = "Cloud-AWS-Apache-Terraform"
} 

variable "availability_zone" {
  description = "Availability zone to use"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type = string
  #default = "c5n.18xlarge"
  default = "t2.micro"
}

variable "managed_policies" {
  description = "The attached IAM policies granting machine permissions"
  default = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess",
             "arn:aws:iam::aws:policy/AmazonS3FullAccess",
             "arn:aws:iam::aws:policy/AmazonFSxFullAccess"]
}

variable "ami_id" {
  description = "The random ID used for AMI creation"
  type = string
  default="unknown value"
}

variable "subnet_prefix" {
  description = "Subnet prefix for cidr_blocks"
  default = [{ cidr_block = "100.0.0.0/24", name = "awi_subnet" }, { cidr_block = "100.1.0.0/24", name = "byu_subnet" }]
}