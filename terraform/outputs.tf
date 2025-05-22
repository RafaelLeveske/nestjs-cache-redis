output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "ec2_public_ip" {
  value = aws_instance.nestjs_ec2.public_ip
}
