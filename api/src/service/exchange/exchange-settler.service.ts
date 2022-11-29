import { Inject, Injectable, Logger } from '@nestjs/common';
import { Pot } from 'module/pot/pot.model';
import { debounceTime, interval, merge, Subject } from 'rxjs';
import { Sequelize } from 'sequelize';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { PotService } from '../../module/pot/pot.service';
import { TransactionService } from '../../module/transaction/transaction.service';
import { ExchangeService } from './exchange.service';

@Injectable()
export class ExchangeSettlerService {
	private readonly logger = new Logger(ExchangeSettlerService.name);

	@Inject() exchangeService: ExchangeService;
	@Inject() lightningNodeService: LightningNodeService;
	@Inject() transactionService: TransactionService;
	@Inject() potService: PotService;
	run = new Subject();

	async onModuleInit() {
		this.transactionService.onAfterCreated.listen(this.run.next);
		merge(this.run, interval(10 * 60 * 1000))
			.pipe(debounceTime(1000))
			.subscribe(this.settle.bind(this));
		await this.settle();
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

	async buy(currency: string, amount: number) {
		this.logger.verbose(`Buying ${amount} of ${currency}`);
		const exchangeFunds = await this.exchangeService.listFunds();
		const totalFunds = await this.getTotalFunds();
		const liabilities = await this.getLiabilities();
		for (const exchange of Object.keys(exchangeFunds)) {
			const surplusCurrencies = Object.keys(
				exchangeFunds[exchange]
			).filter((i) => {
				return totalFunds[i] > liabilities[currency];
			});
			for (const surplusCurrency of surplusCurrencies) {
				const surplusAmount =
					totalFunds[surplusCurrency] -
					(liabilities[surplusCurrency] || 0);

				if (
					(await this.exchangeService.fetchPriceAtTime(
						surplusCurrency,
						currency
					)) *
						Math.min(
							exchangeFunds[exchange][surplusCurrency],
							surplusAmount
						) >
					amount
				) {
					console.log(
						await this.exchangeService.trade(
							surplusCurrency,
							currency,
							amount
						)
					);
					return;
				}
			}
		}
	}

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

	async getTotalFunds() {
		const funds = await this.getFunds();
		return Object.values(funds).reduce((acc, i) => {
			Object.keys(i).forEach((currency) => {
				acc[currency] = acc[currency] || 0;
				acc[currency] += i[currency];
			});
			return acc;
		}, {});
	}

	async settle() {
		this.logger.verbose('Settling balances');
		const funds = await this.getFunds();
		const liabilities = await this.getLiabilities();
		this.logger.verbose('Liabilities', liabilities, 'Funds', funds);
		for (const key of Object.keys(liabilities)) {
			const totalFunds = Object.values(funds).reduce((acc, i) => {
				return acc + (i[key] || 0);
			}, 0);
			if (liabilities[key] > totalFunds) {
				this.logger.log(key + ' funds lower than liabilities');
				await this.buy(key, liabilities[key] - totalFunds);
			}
		}
	}
}
