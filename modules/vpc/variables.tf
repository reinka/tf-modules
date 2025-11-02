variable "cidr_block" {
  description = "VPC CIDR block."
  type = string
}

variable "subnets_config" {
  description = "Map containing the configuration of the VPC subnets."
  type = map(object({
    name = string
    cidr_newbits = number
    cidr_netnum = number
    az_idx = number
    public = bool
  }))
}