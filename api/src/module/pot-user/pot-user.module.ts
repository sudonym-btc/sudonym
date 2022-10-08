import { Module } from '@nestjs/common';
import { SharedModule } from '../shared.module';
import { PotUser } from './pot-user.model';
import { PotUserService } from './pot-user.service';

@Module({
	imports: [SharedModule],
	controllers: [],
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
