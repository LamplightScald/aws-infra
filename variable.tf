variable "cidr" {
  type        = string
  description = "provide CIDR"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
}

variable "region" {
  type        = string
  description = "provide region"
}

variable "profile" {
  type        = string
  description = "provide profile name"
}

variable "name" {
  type        = string
  description = "provide VPC name"
}