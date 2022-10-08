import { Module } from '@nestjs/common';
import { SharedModule } from '../shared.module';
import { ContactAddressController } from './contact-address.controller';
import { ContactAddress } from './contact-address.model';
import { ContactAddressService } from './contact-address.service';

@Module({
	imports: [SharedModule],
	controllers: [ContactAddressController],
	providers: [
		ContactAddressService,
		{
			provide: ContactAddress,
			useValue: ContactAddress,
		},
	],
	exports: [ContactAddressService],
})
export class ContactAddressModule {}
