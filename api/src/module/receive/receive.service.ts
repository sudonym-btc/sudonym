import { Inject, Injectable } from '@nestjs/common';
import { LightningService } from 'src/lightning/lightning.service';
import { TAddressType } from '../pay/pay.service';
import { Receiver } from '../transaction/receiver.model';

@Injectable()
export class ReceiveService {
    @Inject(LightningService) lightningService: LightningService;

    async getInvoice(potId, type: TAddressType, amount) {
        if (type != 'bolt11') {
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
                data = await this.lightningService.createInvoice(amount);
            case 'bolt12':
                data = await this.lightningService.createOffer(amount);
            case 'lnurl':
            case 'onchain':

        }

        return Receiver.create({
            potId, 
            amount,
            data
        });

    }
}