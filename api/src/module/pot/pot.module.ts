import { Module } from '@nestjs/common';
import { PotUserModule } from 'module/pot-user/pot-user.module';
import { SharedModule } from '../shared.module';
import { PotController } from './pot.controller';
import { Pot } from './pot.model';
import { PotService } from './pot.service';

@Module({
	imports: [SharedModule, PotUserModule],
	controllers: [PotController],
	providers: [
		PotService,
		{
			provide: Pot,
			useValue: Pot,
		},
	],
	exports: [PotService],
})
export class PotModule {}
