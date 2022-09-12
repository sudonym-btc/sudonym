import { Module } from '@nestjs/common';
import { LightningNodeModule } from 'src/service/lightning-node/lightning-node.module';

@Module({
	imports: [LightningNodeModule],
	controllers: [],
	exports: [],
	providers: [],
})
export class LightningModule { }