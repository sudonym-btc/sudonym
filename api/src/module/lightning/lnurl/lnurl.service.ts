import { Injectable } from '@nestjs/common';
import { getConfig } from 'config/config';
import { BaseService } from 'module/base.service';
import { LnUrl } from './lnurl.model';
import { RecursivePartial } from 'sequelize-typescript/dist/shared/types';
import { RequestType } from 'helper/parse-request.decorator';
import * as crypto from 'crypto';
import { PaymentRequest, WithdrawRequest } from '@sudonym/models';

@Injectable()
export class LnUrlService extends BaseService(LnUrl) {
	async create(params: RecursivePartial<LnUrl>, req?: RequestType) {
		params.id = crypto.randomUUID();
		const record = await super.create(params, req);
		record.set('params', {
			...record.params,
			callback: getConfig().selfUrl + '/lnurl/handle/' + record.id,
		});
		await record.save();
		return record;
	}

	async serve(id: string): Promise<WithdrawRequest | PaymentRequest> {
		return (await this.findOne(id)).params as any;
	}

	async createPayRequest(mSatoshiAmount?: number) {
		const tag = await this.create({
			params: {
				tag: 'payRequest',
				domain: getConfig().selfUrl,
				minSendable: mSatoshiAmount || 0,
				maxSendable: 10000000,
				metadata: '',
			},
		});

		return tag;
	}

	async createWithdrawRequest(mSatoshiAmount?: number) {
		const tag = await this.create({
			params: {
				tag: 'withdrawRequest',
				domain: getConfig().selfUrl,
				minWithdrawable: mSatoshiAmount || 0,
				maxWithdrawable: 10000000,
				metadata: '',
				defaultDescription: 'Withdrawn desciption',
			},
		});

		return tag;
	}
}
