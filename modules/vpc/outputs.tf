output "id" {
  description = "ID of the VPC."
  value = aws_vpc.this
}

output "igw_id" {
  description = "ID of the internet gateway used for outbound traffic."
  value = aws_internet_gateway.this.id
}

output "subnets" {
  description = "The full map of subnets."
  value = {
    for name, subnet in aws_subnet.public :
    name => {
        id = subnet.id
        cidr_block = subnet.cidr_block
        az = subnet.availability_zone
        public = subnet.map_public_ip_on_launch
    }
  }
}

output "public_subnet_ids" {
  description = "The full list of public subnets."
  value = [
    for k, subnet in aws_subnet.public :
    subnet.id if var.subnets_config[k].public
  ]
}