resource "aws_route53_zone" "private" {
  name = var.privateHzName

  vpc {
    vpc_id     = module.vpc-us-east-1.vpc.id
    vpc_region = var.region
  }
}

output "privateHzName" {
  value = var.privateHzName
}