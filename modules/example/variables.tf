variable "region" {
  type        = string
  description = "vpc region"
  default = "eu-west-1"
}

variable "vpc_name" {
  type        = string
  description = "vpc name"
  default = "IAC demo"
}

variable "vpc_cidr" {
  type        = string
  description = "the IPv4 CIDR block for security vpc"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["eu-west-1a"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24"]
}
 
variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.4.0/24"]
}

variable "instance_connect_endpoint_enabled" {
  type    = bool
  default = false
}