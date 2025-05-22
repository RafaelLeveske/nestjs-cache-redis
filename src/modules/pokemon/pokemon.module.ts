import { Module } from '@nestjs/common';
import { PokemonController } from './infra/http/controllers/pokemon.controller';
import { FindPokemonService } from './services/find-pokemon.service';
import { RedisRepositoryImplementation } from './infra/database/repositories/redis/implementations/redis-repository.implementation';

@Module({
  controllers: [PokemonController],
  providers: [RedisRepositoryImplementation, FindPokemonService],
})
export class PokemonModule {}
