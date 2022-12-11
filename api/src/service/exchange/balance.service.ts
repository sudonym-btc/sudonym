import { forwardRef, Inject, Injectable, Logger } from '@nestjs/common';
import { Pot } from 'module/pot/pot.model';
import { Sequelize } from 'sequelize';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { getRealCurrencyName } from './exchange';
import { ExchangeService } from './exchange.service';

@Injectable()
export class BalanceService {
	private readonly logger = new Logger(BalanceService.name);

	@Inject() lightningNodeService: LightningNodeService;
	@Inject(forwardRef(() => ExchangeService)) exchangeService: ExchangeService;

	async getFunds(): Promise<{ [key: string]: { [key: string]: number } }> {
		const funds = {
			...(await this.exchangeService.listFunds()),
			lightning: {
				BTC: await this.lightningNodeService.listFunds(),
			},
		};
		// Strip zero's from funds
		return Object.keys(funds).reduce(
			(acc, i) => ({
				...acc,
				[i]: Object.keys(funds[i]).reduce(
					(newAcc, newI) => ({
						...newAcc,
						...(!funds[i][newI] ? {} : { [newI]: funds[i][newI] }),
					}),
					{}
				),
			}),
			{}
		);
	}

	async getFundsByRealName(): Promise<{
		[key: string]: { [key: string]: number };
	}> {
		return convertExchangeFundsToRealName(await this.getFunds());
	}

	async getTotalFunds() {
		const acc = {};
		const funds = await this.getFundsByRealName();
		for (const ex of Object.values(funds)) {
			for (const curr of Object.keys(ex)) {
				acc[curr] = acc[curr] || 0;
				acc[curr] += ex[curr];
			}
		}
		return acc;
	}

	async getLiabilities() {
		return await Pot.findAll({
			attributes: [
				[Sequelize.literal('SUM(balance)'), 'balance'],
				'currency',
			],
			raw: true,
			group: ['currency'],
		}).then((i) =>
			i.reduce((acc, i) => ({ ...acc, [i.currency]: i.balance }), {})
		);
	}
}

export const convertExchangeFundsToRealName = (exchanges) => {
	return Object.keys(exchanges).reduce((acc, exchange) => {
		return {
			...acc,
			[exchange]: fundsToRealCurrency(exchanges[exchange]),
		};
	}, {});
};

export const fundsToRealCurrency = (funds) => {
	return Object.keys(funds).reduce((acc, currency) => {
		acc[getRealCurrencyName(currency)] = acc[currency] || 0;
		acc[getRealCurrencyName(currency)] += funds[currency];
		return acc;
	}, {});
};
