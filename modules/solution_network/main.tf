module "vpc" {
  source = "../generic_vpc"

  project_name          = var.project_name
  environment_name      = var.environment_name
  provider_alias_name   = var.provider_alias_name
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  isolated_subnet_cidrs = var.isolated_subnet_cidrs
  nat_gateway_per_az    = var.nat_gateway_per_az
  tags                  = var.tags
}

# This solution module keeps the supporting network controls close to the VPC so
# the root module only decides "which network do I want", not "which SG and VPCE
# resources must exist for that network to be usable by the workload".
resource "aws_security_group" "endpoint" {
  name        = "${var.project_name}-aws-security-group-${var.environment_name}-${var.provider_alias_name}-vpce"
  description = "Allows HTTPS traffic from workload Lambdas into interface VPC endpoints."
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "HTTPS from private Lambda security group"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.private_lambda.id]
  }

  egress {
    description = "Return traffic to workloads"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
}

resource "aws_security_group" "private_lambda" {
  name        = "${var.project_name}-aws-security-group-${var.environment_name}-${var.provider_alias_name}-private-lambda"
  description = "Egress controls for the broker Lambda in the private subnets."
  vpc_id      = module.vpc.vpc_id

  egress {
    description = "Allow HTTPS to internal and external APIs through the NAT or VPC endpoints."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "isolated_lambda" {
  name        = "${var.project_name}-aws-security-group-${var.environment_name}-${var.provider_alias_name}-isolated-lambda"
  description = "Minimal egress policy for the isolated Lambda. The route table still blocks internet access."
  vpc_id      = module.vpc.vpc_id

  egress {
    description = "Permit HTTPS traffic only."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "execute_api" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.primary_region}.execute-api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [aws_security_group.endpoint.id]

  tags = merge(var.tags, { Name = "${var.project_name}-aws-vpc-endpoint-${var.environment_name}-${var.provider_alias_name}-execute-api" })
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.primary_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(module.vpc.private_route_table_ids, module.vpc.isolated_route_table_ids)

  tags = merge(var.tags, { Name = "${var.project_name}-aws-vpc-endpoint-${var.environment_name}-${var.provider_alias_name}-s3" })
}
