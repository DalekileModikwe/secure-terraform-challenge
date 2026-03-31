module "vpc_name" {
  source = "../generic_naming"

  project_name        = var.project_name
  resource_type_name  = "aws-vpc"
  environment_name    = var.environment_name
  provider_alias_name = var.provider_alias_name
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(var.tags, { Name = module.vpc_name.name })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.project_name}-aws-internet-gateway-${var.environment_name}-${var.provider_alias_name}" })
}

module "public_subnet_names" {
  for_each = { for index, az in var.availability_zones : tostring(index) => az }
  source   = "../generic_naming"

  project_name         = var.project_name
  resource_type_name   = "aws-subnet"
  environment_name     = var.environment_name
  provider_alias_name  = var.provider_alias_name
  optional_descriptors = ["public", each.value]
}

resource "aws_subnet" "public" {
  for_each = module.public_subnet_names

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[tonumber(each.key)]
  availability_zone       = var.availability_zones[tonumber(each.key)]
  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = each.value.name, Tier = "public" })
}

module "private_subnet_names" {
  for_each = { for index, az in var.availability_zones : tostring(index) => az }
  source   = "../generic_naming"

  project_name         = var.project_name
  resource_type_name   = "aws-subnet"
  environment_name     = var.environment_name
  provider_alias_name  = var.provider_alias_name
  optional_descriptors = ["private", each.value]
}

resource "aws_subnet" "private" {
  for_each = module.private_subnet_names

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnet_cidrs[tonumber(each.key)]
  availability_zone       = var.availability_zones[tonumber(each.key)]
  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = each.value.name, Tier = "private" })
}

module "isolated_subnet_names" {
  for_each = { for index, az in var.availability_zones : tostring(index) => az }
  source   = "../generic_naming"

  project_name         = var.project_name
  resource_type_name   = "aws-subnet"
  environment_name     = var.environment_name
  provider_alias_name  = var.provider_alias_name
  optional_descriptors = ["isolated", each.value]
}

resource "aws_subnet" "isolated" {
  for_each = module.isolated_subnet_names

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.isolated_subnet_cidrs[tonumber(each.key)]
  availability_zone       = var.availability_zones[tonumber(each.key)]
  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = each.value.name, Tier = "isolated" })
}

resource "aws_eip" "nat" {
  for_each = var.nat_gateway_per_az ? aws_subnet.public : { "0" = aws_subnet.public["0"] }
  domain   = "vpc"

  tags = merge(var.tags, { Name = "${var.project_name}-aws-eip-${var.environment_name}-${var.provider_alias_name}-nat-${each.key}" })
}

resource "aws_nat_gateway" "this" {
  for_each = aws_eip.nat

  allocation_id = each.value.id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(var.tags, { Name = "${var.project_name}-aws-nat-gateway-${var.environment_name}-${var.provider_alias_name}-${each.key}" })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, { Name = "${var.project_name}-aws-route-table-${var.environment_name}-${var.provider_alias_name}-public" })
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[var.nat_gateway_per_az ? each.key : "0"].id
  }

  tags = merge(var.tags, { Name = "${var.project_name}-aws-route-table-${var.environment_name}-${var.provider_alias_name}-private-${each.key}" })
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table" "isolated" {
  for_each = aws_subnet.isolated
  vpc_id   = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.project_name}-aws-route-table-${var.environment_name}-${var.provider_alias_name}-isolated-${each.key}" })
}

resource "aws_route_table_association" "isolated" {
  for_each       = aws_subnet.isolated
  subnet_id      = each.value.id
  route_table_id = aws_route_table.isolated[each.key].id
}
