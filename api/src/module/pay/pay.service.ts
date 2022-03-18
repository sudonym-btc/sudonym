import { Inject, Injectable } from '@nestjs/common';
import bolt11 from 'bolt11';
import lnurl from 'lnurl';
import { LightningService } from '../lightning/lightning.service';
console.log(lnurl);

@Injectable()
export class PayService {
    @Inject(LightningService) lightningService: LightningService;

    async getInfo(address, amount) {
        const t = getAddressType(address);
        switch(t) {
            case 'bolt11':
                return this.lightningService.getRoute(bolt11.decode(address).payeeNodeKey);
            case 'bolt12':
                const offerInvoice = await this.lightningService.fetchOfferInvoice(address);
                return this.lightningService.getRoute(bolt11.decode(address).payeeNodeKey);
            // case 'lnurl': 
                

        }
    }

    pay(address, amount) {
        
    }
}
export const ADDRESS_TYPES = ['lnurl', 'bolt11', 'bolt12', 'onchain'];
export type TAddressType= 'lnurl' | 'bolt12' | 'onchain' | 'bolt11';

export const getAddressType = (address: string): TAddressType => {
    if(address.startsWith('lnurl1')) {
        return 'lnurl';
    } else if(address.startsWith('lno1')) {
        return 'bolt12';
    } else if(address.startsWith('lnbc') || address.startsWith('lntb') || address.startsWith('lntbs') || address.startsWith('lnbcrt')) {
        return 'bolt11';
    } else {
        return 'onchain';
    }
}