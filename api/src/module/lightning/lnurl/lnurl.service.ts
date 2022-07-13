import { Injectable } from '@nestjs/common';
import { getConfig } from 'src/config/config';
import { BaseService } from 'src/module/base.service';
import { LnUrl } from './lnurl.model';
import { RecursivePartial } from 'sequelize-typescript/dist/shared/types';
import { RequestType } from 'src/helper/parse-request.decorator';
import * as crypto from 'crypto';

@Injectable()
export class LnUrlService extends BaseService(LnUrl) {

    handle(payload: LnUrl) {
        switch (payload.tag) {
            case 'withdrawRequest':
                return this.handleWithdrawRequest(payload);
            case 'payRequest':
                return this.handlePayRequest(payload);
        }
    }

    handlePayRequest(payload: LnUrl) {

    }

    handleWithdrawRequest(payload: LnUrl) {

    }

    async create(params: RecursivePartial<LnUrl>, req?: RequestType) {
        params.id = crypto.randomUUID();
        const record = await super.create(params, req);
        record.set('params', {
            ...record.params, callback: getConfig().selfUrl + '/lnurl/handle/' + record.id,
        }); 
        await record.save();
        return record;
    }

    async createPayRequest(potId: number, amount?: number) {
        const tag = await this.create({
            tag: 'payRequest',
            params: {
                tag: 'payRequest',
                domain: getConfig().selfUrl,
                minSendable: amount,
                maxSendable: 10000000,
                metadata: '',
                commentAllowed: 500,
            }
        });

        return tag;
    }
}