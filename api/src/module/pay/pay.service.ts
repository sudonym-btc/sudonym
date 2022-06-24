import { Inject, Injectable } from '@nestjs/common';
import { TransactionConfirm } from '@sudonym/models';
import { Transaction } from 'bitcoinjs-lib';
import * as bolt11 from 'bolt11';
import lnurl from 'lnurl';
import { LightningService } from '../lightning/lightning.service';
import { TransactionService } from '../transaction/transaction.service';
console.log(lnurl);

const convertBolt11ToPaymentInfo = (address, amount, route): TransactionConfirm => {
    console.log(route);
    return new TransactionConfirm(address, address, 0, amount || 1000, null);
}

@Injectable()
export class PayService {
    @Inject(LightningService) lightningService: LightningService;
    @Inject(TransactionService) transactionService: TransactionService;

    async getInfo(address, amount): Promise<TransactionConfirm> {
        const t = getAddressType(address);
        switch (t) {
            case 'bolt11':
                return convertBolt11ToPaymentInfo(
                    address,
                    amount,
                    await this.lightningService.getRoute(bolt11.decode(address).payeeNodeKey));
            case 'bolt12':
                const offerInvoice = await this.lightningService.fetchOfferInvoice(address);
                return convertBolt11ToPaymentInfo(
                    address,
                    amount,
                    await this.lightningService.getRoute(bolt11.decode(address).payeeNodeKey));
            // case 'lnurl': 


        }
    }

    async pay(address, amount): Promise<Transaction> {
        console.log(await this.lightningService.pay(address));
        return this.transactionService.create({
            
        });
    }
}
export const ADDRESS_TYPES = ['lnurl', 'bolt11', 'bolt12', 'onchain'];
export type TAddressType = 'lnurl' | 'bolt12' | 'onchain' | 'bolt11';

export const getAddressType = (address: string): TAddressType => {
    if (address.startsWith('lnurl1')) {
        return 'lnurl';
    } else if (address.startsWith('lno1')) {
        return 'bolt12';
    } else if (address.startsWith('lnbc') || address.startsWith('lntb') || address.startsWith('lntbs') || address.startsWith('lnbcrt')) {
        return 'bolt11';
    } else {
        return 'onchain';
    }
}