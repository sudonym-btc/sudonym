import { Inject, Injectable } from '@nestjs/common';
import { Payment } from '@sudonym/models';
import { Transaction } from 'bitcoinjs-lib';
import * as bolt11 from 'bolt11';
import lnurl from 'lnurl';
import { LightningNodeService } from 'src/service/lightning-node/lightning-node.service';
import { TransactionService } from '../transaction/transaction.service';
console.log(lnurl);

const convertBolt11ToPaymentInfo = (address, amount, route): Payment => {
    console.log(route);
    return new Payment(address, address, amount || 0, 1000);
}

@Injectable()
export class PayService {
    @Inject(LightningNodeService) LightningNodeService: LightningNodeService;
    @Inject(TransactionService) transactionService: TransactionService;

    async getInfo(address, amount): Promise<Payment> {
        const t = getAddressType(address);

        switch (t) {
            case 'bolt11':
                return convertBolt11ToPaymentInfo(
                    address,
                    amount,
                    await this.LightningNodeService.getRoute(bolt11.decode(address).payeeNodeKey, amount));
            case 'bolt12':
                const offerInvoice = await this.LightningNodeService.fetchOfferInvoice(address);
                return convertBolt11ToPaymentInfo(
                    address,
                    amount,
                    await this.LightningNodeService.getRoute(bolt11.decode(address).payeeNodeKey, amount));
            // case 'lnurl': 

            case 'onchain':
                return convertBolt11ToPaymentInfo(
                    address,
                    amount,
                    1000);
        }
    }

    async pay(address, amount = 0, potId = '1'): Promise<Transaction> {

        return this.transactionService.create({
            address,
            addressType: getAddressType(address),
            amount,
            outgoing: true,
            potId
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