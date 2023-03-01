
resource "aws_elasticache_replication_group" "redis" {
  automatic_failover_enabled = false
  replication_group_id       = local.resourcePrefix
  description                = local.resourcePrefix
  node_type                  = "cache.m4.large"
  num_cache_clusters         = 1
  parameter_group_name       = "default.redis7"
  engine                     = "redis"
  engine_version             = "7.0"
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = local.securityGroupIds

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = var.redis_auth
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${local.resourcePrefix}-redis"
  subnet_ids = local.subnetIds
}

output "redis" {
  value = "${aws_elasticache_replication_group.redis.primary_endpoint_address}:${aws_elasticache_replication_group.redis.port}"
}