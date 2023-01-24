import { Module } from '@nestjs/common';
import { PotModule } from 'module/pot/pot.module';
import { SharedModule } from '../shared.module';
import { TransactionTagController } from './transaction-tag.controller';
import { TransactionTag } from './transaction-tag.model';
import { TransactionTagService } from './transaction-tag.service';

@Module({
	imports: [SharedModule, PotModule],
	controllers: [TransactionTagController],
	providers: [
		TransactionTagService,
		{
			provide: TransactionTag,
			useValue: TransactionTag,
		},
	],
	exports: [TransactionTagService],
})
export class TransactionTagModule {}
