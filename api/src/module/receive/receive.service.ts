import { Inject, Injectable } from '@nestjs/common';
import { LightningService } from 'src/module/lightning/lightning.service';
import { TAddressType } from '../pay/pay.service';
import { Receiver } from './receiver.model';
import { LnUrlService } from '../lightning/lnurl/lnurl.service';

@Injectable()
export class ReceiveService {
    @Inject(LightningService) lightningService: LightningService;
    @Inject(LnUrlService) lnUrlService: LnUrlService;

    async getInvoice(potId, type: TAddressType, amount) {

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
                data = (await this.lightningService.createInvoice(amount)).bolt11;
            case 'bolt12':
                data = (await this.lightningService.createOffer(1000)).bolt12;
            case 'lnurl':
                data = (await this.lnUrlService.getPayRequest(potId));
            case 'onchain':
                data = (await this.lightningService.generateOnChainAddress());
        }

        return Receiver.create({
            potId, 
            amount: Number(amount),
            type,
            data
        });

    }
}