import { Inject, Injectable } from '@nestjs/common';
import { PotService } from 'module/pot/pot.service';
import { BaseService } from '../base.service';
import { Transaction } from './transaction.model';

@Injectable()
export class TransactionService extends BaseService(Transaction) {
    @Inject() potService: PotService;

    async onModuleInit() {
        this.beforeCreate.hook(async params => {
            params.potId = params.potId || (await this.potService.findForUser()).id
        })
    }
}
