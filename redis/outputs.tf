output "endpoint" {
  value = aws_elasticache_serverless_cache.redis.endpoint[0].address
}
