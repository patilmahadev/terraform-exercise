variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "region" {
  default = "us-east-1"
}

variable "pub_key_path" {
  default = "/root/.ssh/id_rsa.pub"
}

variable "ami" {
  type = "map"
  default = {
    us-east-1 = "ami-cfe4b2b0"
    us-east-2 = "ami-40142d25"
    us-west-1 = "ami-0e86606d"
  }
}

variable "instancetype" {
  default = "t2.micro"
}
