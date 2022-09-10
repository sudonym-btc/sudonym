import { Module } from '@nestjs/common';
import { PotModule } from 'src/module/pot/pot.module';
import { SettlementModule } from 'src/module/settlement/settlement.module';
import { TransactionModule } from 'src/module/transaction/transaction.module';
import { ExchangeSettler } from './exchange-settler';

@Module({
    imports: [TransactionModule, PotModule, SettlementModule],
    controllers: [],
    providers: [ExchangeSettler],
    exports: [],
})
export class ExchangeSettlerModule { }