import { Inject, Injectable, Logger } from '@nestjs/common';
import { AddressParseResponse, MSATOSHIS, Payment, TAddressType } from '@sudonym/models';
import * as bolt11 from 'bolt11';
import * as lnurl from 'lnurl';
import { LightningNodeService } from '../../service/lightning-node/lightning-node.service';
import { CurrencyService } from '../currency/currency.service';
import { LnUrlHandlerService } from '../lightning/lnurl/lnurl-handler/lnurl-handler.service';
import { Transaction } from '../transaction/transaction.model';
import { TransactionService } from '../transaction/transaction.service';
import { AddressParser, validateInternetIdentifier } from './address-parser';

@Injectable()
export class PayService {
    @Inject(CurrencyService) currencyService: CurrencyService;
    @Inject(LightningNodeService) lightningNodeService: LightningNodeService;
    @Inject(LnUrlHandlerService) lnUrlHandlerService: LnUrlHandlerService;
    @Inject(TransactionService) transactionService: TransactionService;
    @Inject(AddressParser) addressParser: AddressParser;
    private readonly logger = new Logger(PayService.name);

    async parseInvoice(invoice): Promise<AddressParseResponse> {
        return await this.addressParser.parse(invoice);
    }

    async getInfo(p: Payment): Promise<Payment> {
        const t = getAddressType(p.originalAddress);

        p.currency = p.currency || "BTC";
        var amountInBTC = p.currency == "BTC" ? p.amount : (await this.currencyService.convert(p.currency, "BTC", p.amount)).amount;
        var mSatoshiAmount = Math.round(amountInBTC * MSATOSHIS);
        
        this.logger.debug("Getting invoice for");
        this.logger.debug(p);
        switch (t) {
            case 'bolt11':
                p.address = p.originalAddress;
                p.feeMSat = await this.lightningNodeService.getFees(bolt11.decode(p.address).payeeNodeKey, mSatoshiAmount);
                return p;
            case 'bolt12':
                const offerInvoice = await this.lightningNodeService.fetchOfferInvoice(p.address);
                // return convertBolt11ToPaymentInfo(
                //     p.address,
                //     p.amount,
                //     await this.lightningNodeService.getRoute(bolt11.decode(p.address).payeeNodeKey, p.amount));
            case 'lightningaddress':
            case 'lnurl':
                const callbackInfo = await this.lnUrlHandlerService.getCallback(p.addressParseResponse.data.params.callback, { amount: mSatoshiAmount });
                console.log(callbackInfo);
                p.address = callbackInfo.pr;
                return p;

            case 'onchain':
                return p;
        }
    }

    async pay(p: Payment): Promise<Transaction> {   
        return this.transactionService.create({
            originalAddress: p.originalAddress,
            address: p.address,
            type: getAddressType(p.originalAddress),
            amount: p.amount,
            currencyCode: p.currency,
            outgoing: true,
            potId: p.potId
        });

    }
}

export const getAddressType = (address: string): TAddressType => {
    if (validateInternetIdentifier(address)) {
        return 'lightningaddress';
    } else if (address.startsWith('lnurl1')) {
        return 'lnurl';
    } else if (address.startsWith('lno1')) {
        return 'bolt12';
    } else if (address.startsWith('lnbc') || address.startsWith('lntb') || address.startsWith('lntbs') || address.startsWith('lnbcrt')) {
        return 'bolt11';
    } else {
        return 'onchain';
    }
}