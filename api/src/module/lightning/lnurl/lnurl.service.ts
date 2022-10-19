import { Injectable } from '@nestjs/common';
import { getConfig } from 'config/config';
import { BaseService } from 'module/base.service';
import { LnUrl } from './lnurl.model';
import { RecursivePartial } from 'sequelize-typescript/dist/shared/types';
import { RequestType } from 'helper/parse-request.decorator';
import * as crypto from 'crypto';
import { PaymentRequest, WithdrawRequest } from '@sudonym/models';
import { v4 as uuid } from 'uuid';

@Injectable()
export class LnUrlService extends BaseService(LnUrl) {
	onModuleInit() {
		this.beforeCreate.hook(async (params) => {
			params.id = crypto.randomUUID();
			params.params.callback =
				getConfig().selfUrl + '/lnurl/handle/' + params.id;
		});
	}
	async serve(id: string): Promise<WithdrawRequest | PaymentRequest> {
		return (await this.findOne(id)).params as any;
	}

	async createPayRequest(mSatoshiAmount?: number) {
		const tag = await this.create({
			params: {
				tag: 'payRequest',
				domain: getConfig().selfUrl,
				minSendable: Math.max(mSatoshiAmount, 1),
				maxSendable: 10000000,
				metadata: JSON.stringify([
					[
						'text/plain', // mandatory,
						'Short description sudo', // short description displayed when paying and in transaction log
					],
					[
						'text/long-desc', // optional
						'Long description sudo', // longer description of the payment, MAY contain newlines
					],
					// [
					// 	"image/png;base64",
					// 	string // base64 string, optional 512x512px PNG thumbnail which will represent this lnurl in a list or grid. Up to 136536 characters (100Kb of image data in base-64 encoding)
					// ],
					// [
					// 	"image/jpeg;base64", // optional
					// 	string // base64 string, 512x512px JPG thumbnail which will represent this lnurl in a list or grid. Up to 136536 characters (100Kb of image data in base-64 encoding)
					// ],
				]),
			},
		});

		return tag;
	}

	async createWithdrawRequest(params: RecursivePartial<WithdrawRequest> = {}) {
		const tag = await this.create({
			params: {
				tag: 'withdrawRequest',
				domain: getConfig().selfUrl,
				minWithdrawable: 0,
				maxWithdrawable: 99999999,
				k1: uuid(),
				...params,
				// "balanceCheck": string,
				// "payLink": string
				defaultDescription: 'Withdrawn desciption',
			},
		});

		return tag;
	}
}
