import { Injectable } from '@nestjs/common';
import { getConfig } from 'config/config';
import { BaseService } from 'module/base.service';
import { LnUrl } from './lnurl.model';
import { RecursivePartial } from 'sequelize-typescript/dist/shared/types';
import { RequestType } from 'helper/parse-request.decorator';
import * as crypto from 'crypto';

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

	async createPayRequest(potId: number, mSatoshiAmount?: number) {
		const tag = await this.create({
			tag: 'payRequest',
			potId,
			params: {
				tag: 'payRequest',
				domain: getConfig().selfUrl,
				minSendable: mSatoshiAmount || 0,
				maxSendable: 10000000,
				metadata: '',
				commentAllowed: 500,
			},
		});

		return tag;
	}

	async createWithdrawRequest(potId: number, mSatoshiAmount?: number) {
		const tag = await this.create({
			tag: 'withdrawRequest',
			potId,
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
