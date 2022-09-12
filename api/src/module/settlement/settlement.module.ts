import { Module } from '@nestjs/common';
import { SharedModule } from '../shared.module';
import { Settlement } from './settlement.model';
import { SettlementService } from './settlement.service';

@Module({
	imports: [SharedModule],
	controllers: [],
	providers: [SettlementService, {
		provide: Settlement,
		useValue: Settlement,
	},],
	exports: [SettlementService],
})
export class SettlementModule { }