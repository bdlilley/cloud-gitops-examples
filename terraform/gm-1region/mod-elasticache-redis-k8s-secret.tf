
resource "kubernetes_secret" "redis-tester" {
  provider = kubernetes.cluster
  depends_on = [
    module.eks,
  ]
  metadata {
    name      = "redis-config"
    namespace = "default"
  }

  data = {
    token   = var.redis_auth
    address = "${aws_elasticache_replication_group.redis.primary_endpoint_address}:${aws_elasticache_replication_group.redis.port}"
  }
}