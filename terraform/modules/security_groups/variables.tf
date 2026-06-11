variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "wordpress_port" {
  type    = number
  default = 80
}

variable "tags" {
  type    = map(string)
  default = {}
}
