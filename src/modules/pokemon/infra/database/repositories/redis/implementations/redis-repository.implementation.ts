import { Injectable, OnModuleInit } from '@nestjs/common';
import Redis from 'ioredis';
import { RedisRepositoryModel } from '../models/redis-repository.model';

@Injectable()
export class RedisRepositoryImplementation implements OnModuleInit, RedisRepositoryModel {
  private client: Redis;

  onModuleInit() {
    this.client = new Redis({
      host: process.env.REDIS_HOST,
      port: Number(process.env.REDIS_PORT),
    });
  }

  async get(key: string): Promise<string | null> {
    return this.client.get(key);
  }

  async set(key: string, value: string, ttl = 60): Promise<string> {
    return this.client.set(key, value, 'EX', ttl);
  }
}
