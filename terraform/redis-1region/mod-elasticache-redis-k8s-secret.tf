
resource "kubernetes_secret" "redis-tester" {
  depends_on = [
    module.eks,
  ]
  metadata {
    name      = "redis-config"
    namespace = "default"
  }

  data = {
    token = var.redis_auth
    host  = aws_elasticache_replication_group.redis.primary_endpoint_address
    port  = aws_elasticache_replication_group.redis.port
  }
}