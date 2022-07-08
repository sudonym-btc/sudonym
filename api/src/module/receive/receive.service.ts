import { Inject, Injectable } from '@nestjs/common';
import { TAddressType } from '../pay/pay.service';
import { Receiver } from './receiver.model';
import { LnUrlService } from '../lightning/lnurl/lnurl.service';
import { LightningNodeService } from 'src/service/lightning-node/lightning-node.service';
import { BaseService } from '../base.service';

@Injectable()
export class ReceiveService extends BaseService(Receiver) {
    @Inject(LightningNodeService) LightningNodeService: LightningNodeService;
    @Inject(LnUrlService) lnUrlService: LnUrlService;

    async getInvoice(potId, type: TAddressType, amount = 0) {

        if (type != 'bolt11' && type != 'lnurl') {
            const exists = await Receiver.findOne({
                where: {
                    potId,
                    type,
                    amount
                }
            });
            if (exists)
                return exists;
        }
        let data;

        switch (type) {
            case 'bolt11':
                data = (await this.LightningNodeService.createInvoice(amount)).bolt11;
                break;
            case 'bolt12':
                data = (await this.LightningNodeService.createOffer(amount)).bolt12;
                break;
            case 'lnurl':
                data = (await this.lnUrlService.getPayRequest(potId));
                break;
            case 'onchain':
                data = (await this.LightningNodeService.generateOnChainAddress()).address;
                break;
        }
        return Receiver.create({
            potId, 
            amount: Number(amount),
            type,
            data
        });

    }
}