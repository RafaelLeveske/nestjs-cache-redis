import { Injectable } from '@nestjs/common';
import axios from 'axios';
import { RedisRepositoryImplementation } from '../infra/database/repositories/redis/implementations/redis-repository.implementation';

@Injectable()
export class FindPokemonService {
  constructor(private readonly redisRepositoryImplementation: RedisRepositoryImplementation) {}

  async getPokemon(name: string) {
    const cacheKey = `pokemon:${name}`;
    const cached = await this.redisRepositoryImplementation.get(cacheKey);

    if (cached) {
      return JSON.parse(cached);
    }

    const response = await axios.get(`https://pokeapi.co/api/v2/pokemon/${name}`);
    const data = response.data;

    await this.redisRepositoryImplementation.set(cacheKey, JSON.stringify(data));
    return data;
  }
}
