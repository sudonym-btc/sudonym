import { Module } from '@nestjs/common';
import { LightningNodeModule } from 'service/lightning-node/lightning-node.module';
import { AddressParser } from './address-parser';

@Module({
	imports: [LightningNodeModule],
	controllers: [],
	providers: [AddressParser],
	exports: [AddressParser],
})
export class AddressParserModule {}
