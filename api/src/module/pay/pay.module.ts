import { Module } from '@nestjs/common';
import { LightningNodeModule } from 'src/service/lightning-node/lightning-node.module';
import { CurrencyModule } from '../currency/currency.module';
import { LnUrlHandlerModule } from '../lightning/lnurl/lnurl-handler/lnurl-handler.module';
import { SharedModule } from '../shared.module';
import { TransactionModule } from '../transaction/transaction.module';
import { AddressParser } from './address-parser';
import { PayController } from './pay.controller';
import { PayService } from './pay.service';

@Module({
  imports: [SharedModule, CurrencyModule, LnUrlHandlerModule, LightningNodeModule, TransactionModule],
  controllers: [PayController],
  providers: [PayService, AddressParser],
  exports: [PayService],
})
export class PayModule { }