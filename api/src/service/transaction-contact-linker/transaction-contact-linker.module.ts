import { Module } from '@nestjs/common';
import { ContactAddressModule } from 'module/contact-address/contact-address.module';
import { ContactModule } from 'module/contact/contact.module';
import { TransactionModule } from 'module/transaction/transaction.module';
import { TransactionContactLinkerService } from './transaction-contact-linker.service';

@Module({
	imports: [TransactionModule, ContactAddressModule, ContactModule],
	controllers: [],
	providers: [TransactionContactLinkerService],
	exports: [],
})
export class TransactionContactLinkerModule {}
