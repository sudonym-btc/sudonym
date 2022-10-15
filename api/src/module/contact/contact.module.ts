import { Module } from '@nestjs/common';
import { ContactAddressModule } from 'module/contact-address/contact-address.module';
import { SharedModule } from '../shared.module';
import { ContactController } from './contact.controller';
import { Contact } from './contact.model';
import { ContactService } from './contact.service';

@Module({
	imports: [SharedModule, ContactAddressModule],
	controllers: [ContactController],
	providers: [
		ContactService,
		{
			provide: Contact,
			useValue: Contact,
		},
	],
	exports: [ContactService],
})
export class ContactModule {}
