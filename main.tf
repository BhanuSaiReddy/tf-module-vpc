resource "aws_vpc" "main" {
  cidr_block = var.cidr
}
module "subnets" {
  source = "./subnets"
  for_each = var.subnets
  subnets = each.value
  vpc_id = aws_vpc.main.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route" "igw" {
  for_each = try(lookup(module.subnets, "public"), {})

  route_table_id         = length(each.value.route_table_ids) > 0 ? each.value.route_table_ids[0] : null
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}




output "subnet" {
  value = module.subnets
}






