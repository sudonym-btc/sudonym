import { Inject, Injectable } from '@nestjs/common';
import { Receiver } from './receiver.model';
import { LnUrlService } from '../lightning/lnurl/lnurl.service';
import { LightningNodeService } from 'src/service/lightning-node/lightning-node.service';
import { BaseService } from '../base.service';
import * as lnurl from 'lnurl';
import { getConfig } from 'src/config/config';
import { TAddressType } from '@sudonym/models';

@Injectable()
export class ReceiveService extends BaseService(Receiver) {
    @Inject(LightningNodeService) lightningNodeService: LightningNodeService;
    @Inject(LnUrlService) lnUrlService: LnUrlService;

    async getInvoice(potId, type: TAddressType, amount = 0) {

        amount = (Math.round(amount));

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
                data = (await this.lightningNodeService.createInvoice(amount)).bolt11;
                break;
            case 'bolt12':
                data = (await this.lightningNodeService.createOffer(amount)).bolt12;
                break;
            case 'lnurl':
                const tag = await this.lnUrlService.createPayRequest(potId, amount);
                data = lnurl.encode(getConfig().selfUrl + '/lnurl/' + tag.id);;
                break;
            case 'onchain':
                data = (await this.lightningNodeService.generateOnChainAddress()).address;
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