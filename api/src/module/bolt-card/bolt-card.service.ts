import { Inject, Injectable } from '@nestjs/common';
import { RequestType } from 'helper/parse-request.decorator';
import { SenderService } from 'module/sender/sender.service';
import { RecursivePartial } from 'sequelize-typescript/dist/shared/types';
import { BaseService } from '../base.service';
import { BoltCard } from './bolt-card.model';

@Injectable()
export class BoltCardService extends BaseService(BoltCard) {

    @Inject() senderService: SenderService;

    async create(params: RecursivePartial<BoltCard>, req?: RequestType): Promise<BoltCard> {
        const sender = await this.senderService.create({
            ...params.sender,
            type: 'lnurl',
        }, req);
        return super.create({
            senderId: sender.id,
            ...params
        }, req);
    }
}
