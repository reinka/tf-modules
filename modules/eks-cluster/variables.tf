variable "name" {
  description = "Name prefix to add to created resources."
  type = string
}

variable "public_access_cidrs" {
  type = list(string)
}