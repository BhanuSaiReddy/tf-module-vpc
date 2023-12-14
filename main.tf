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
  for_each                  = lookup(lookup(module.subnets, "public", {}), "route_table_ids", {})
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id

  # Iterate over the subnets and create a route for each
  dynamic "route" {
    for_each = each.value
    content {
      route_table_id = route["id"]
    }
  }
}



output "subnet" {
  value = module.subnets
}






