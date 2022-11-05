import { Inject, Injectable } from '@nestjs/common';
import { MSATOSHIS, WithdrawRequest } from '@sudonym/models';
import { Config } from 'config/config';
import * as crypto from 'crypto';
import { BaseService } from 'module/base.service';
import { RecursivePartial } from 'sequelize-typescript/dist/shared/types';
import { v4 as uuid } from 'uuid';
import { LnUrl } from './lnurl.model';

@Injectable()
export class LnUrlService extends BaseService(LnUrl) {
	@Inject(Config) private readonly config: Config;

	onModuleInit() {
		this.beforeCreate.hook(async (params) => {
			params.id = crypto.randomUUID();
			params.params.callback =
				this.config.selfUrl + '/lnurl/handle/' + params.id;
		});
	}

	async createPayRequest(mSatoshiAmount?: number) {
		const tag = await this.create({
			params: {
				tag: 'payRequest',
				domain: this.config.selfUrl,
				minSendable: Math.max(mSatoshiAmount, 1000),
				maxSendable: 0.01 * MSATOSHIS,
				commentAllowed: true,
				metadata: JSON.stringify([
					[
						'text/plain', // mandatory,
						'sudonym payment', // short description displayed when paying and in transaction log
					],
					// [
					// 	'text/long-desc', // optional
					// 	'Long description sudo', // longer description of the payment, MAY contain newlines
					// ],
				]),
			},
		});

		return tag;
	}

	async createWithdrawRequest(
		params: RecursivePartial<WithdrawRequest> = {}
	) {
		const tag = await this.create({
			params: {
				tag: 'withdrawRequest',
				domain: this.config.selfUrl,
				minWithdrawable: 0,
				maxWithdrawable: 0.001 * MSATOSHIS,
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
