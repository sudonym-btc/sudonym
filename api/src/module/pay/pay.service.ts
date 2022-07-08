import { Inject, Injectable } from '@nestjs/common';
import { AddressParseResponse, Payment } from '@sudonym/models';
import { Transaction } from 'bitcoinjs-lib';
import * as bolt11 from 'bolt11';
import lnurl from 'lnurl';
import { LightningNodeService } from '../../service/lightning-node/lightning-node.service';
import { TransactionService } from '../transaction/transaction.service';
import { AddressParser } from './address-parser';

@Injectable()
export class PayService {
    @Inject(LightningNodeService) lightningNodeService: LightningNodeService;
    @Inject(TransactionService) transactionService: TransactionService;
    @Inject(AddressParser) addressParser: AddressParser;

    async parseInvoice(invoice): Promise<AddressParseResponse> {
        return  await this.addressParser.parse(invoice);
    }

    async getInfo(address, amount): Promise<Payment> {
        const t = getAddressType(address);

        switch (t) {
            case 'bolt11':
                return convertBolt11ToPaymentInfo(
                    address,
                    amount,
                    await this.lightningNodeService.getRoute(bolt11.decode(address).payeeNodeKey, amount));
            case 'bolt12':
                const offerInvoice = await this.lightningNodeService.fetchOfferInvoice(address);
                return convertBolt11ToPaymentInfo(
                    address,
                    amount,
                    await this.lightningNodeService.getRoute(bolt11.decode(address).payeeNodeKey, amount));
            // case 'lnurl': 

            case 'onchain':
                return convertBolt11ToPaymentInfo(
                    address,
                    amount,
                    1000);
        }
    }

    async pay(address, amount = 0, potId = 1): Promise<Transaction> {

        return this.transactionService.create({
            address,
            type: getAddressType(address),
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


const convertBolt11ToPaymentInfo = (address, amount = 0, route): Payment => {
    return new Payment(null, address, address, amount, amount, amount, 1000);
}