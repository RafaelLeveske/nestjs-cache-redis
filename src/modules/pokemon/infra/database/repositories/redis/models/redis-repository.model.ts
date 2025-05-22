export interface RedisRepositoryModel {
  get(key: string): Promise<string | null>;
  set(key: string, value: string, ttl?: number): Promise<string>;
}