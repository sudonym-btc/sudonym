import { Module } from '@nestjs/common';
import { PotUser } from './pot-user.model';
import { PotUserService } from './pot-user.service';

@Module({
  imports: [],
  controllers: [],
  providers: [PotUserService, {
    provide: PotUser,
    useValue: PotUser,
  },],
  exports: [PotUserService],
})
export class PotUserModule { }