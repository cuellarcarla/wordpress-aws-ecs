variable "name_prefix" {
  description = "Prefijo para nombrar recursos"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "wordpress_port" {
  description = "Puerto de WordPress"
  type        = number
  default     = 80
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default     = {}
}
