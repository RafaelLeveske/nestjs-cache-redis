import { Controller, Get, Param } from '@nestjs/common';
import { FindPokemonService } from 'src/modules/pokemon/services/find-pokemon.service';

@Controller('pokemon')
export class PokemonController {
  constructor(private readonly findpokemonService: FindPokemonService) {}

  @Get(':name')
  async getPokemon(@Param('name') name: string) {
    return this.findpokemonService.getPokemon(name);
  }
}
