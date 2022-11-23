import { Module } from '@nestjs/common';
import { SharedModule } from '../shared.module';
import { PotUserController } from './pot-user.controller';
import { PotUser } from './pot-user.model';
import { PotUserService } from './pot-user.service';

@Module({
	imports: [SharedModule],
	controllers: [PotUserController],
	providers: [
		PotUserService,
		{
			provide: PotUser,
			useValue: PotUser,
		},
	],
	exports: [PotUserService],
})
export class PotUserModule {}
