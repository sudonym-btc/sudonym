import { Module } from '@nestjs/common';
import { SharedModule } from '../shared.module';
import { BoltCardController } from './bolt-card.controller';
import { BoltCard } from './bolt-card.model';
import { BoltCardService } from './bolt-card.service';

@Module({
	imports: [SharedModule],
	controllers: [BoltCardController],
	providers: [
		BoltCardService,
		{
			provide: BoltCard,
			useValue: BoltCard,
		},
	],
	exports: [BoltCardService],
})
export class BoltCardModule {}
