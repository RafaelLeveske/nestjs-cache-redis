provider "aws" {
  region = "us-east-1"
}

#######################
# VPC e Subnets
#######################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
}

#######################
# Security Group
#######################

resource "aws_security_group" "redis_sg" {
  name        = "redis-sg"
  description = "Allow Redis access from EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ideal restringir para o IP da EC2
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#######################
# Redis Subnet Group
#######################

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

#######################
# ElastiCache Redis
#######################

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "nestjs-redis-cluster"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [aws_security_group.redis_sg.id]
}

#######################
# SSM Parameters
#######################

resource "aws_ssm_parameter" "redis_host" {
  name  = "/nestjs-cache/REDIS_HOST"
  type  = "String"
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}

resource "aws_ssm_parameter" "redis_port" {
  name  = "/nestjs-cache/REDIS_PORT"
  type  = "String"
  value = "6379"
}

#######################
# IAM Role for EC2 (SSM access)
#######################

resource "aws_iam_role" "ec2_ssm_role" {
  name = "nestjs-cache-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "ssm_access_policy" {
  name = "ssm-parameter-access"
  role = aws_iam_role.ec2_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "nestjs-cache-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

#######################
# EC2 para rodar NestJS
#######################

resource "aws_instance" "nestjs_ec2" {
  ami                    = "ami-0c02fb55956c7d316" # Ubuntu 22.04 LTS (verifique região)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_1.id
  vpc_security_group_ids = [aws_security_group.redis_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  key_name               = "test-key"

  tags = {
    Name = "nestjs-api"
  }
}
