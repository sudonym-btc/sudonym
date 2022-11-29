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
		this.transactionService.onAfterCreated.listen(
			this.run.next.bind(this.run)
		);
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
		this.logger.debug(`Buying ${amount} of ${currency}`);
		const exchangeFunds = await this.exchangeService.listFunds();
		const exchangeFundsByRealName = Object.keys(exchangeFunds).reduce(
			(acc, i) => {
				return {
					...acc,
					[i]: Object.keys,
				};
			},
			{}
		);
		const totalFunds = await this.getTotalFunds();
		const liabilities = await this.getLiabilities();

		// For each exchange
		for (const exchange of Object.keys(exchangeFunds)) {
			// Check which currencies on this exchange we have more of than liabilties
			const surplusCurrencies = Object.keys(
				exchangeFunds[exchange]
			).filter((i) => {
				return (
					totalFunds[this.exchangeService.getRealName(i)] >
					liabilities[currency]
				);
			});
			// For each surplus currency
			for (const surplusCurrency of surplusCurrencies) {
				const surplusAmount =
					totalFunds[surplusCurrency] -
					(liabilities[surplusCurrency] || 0);

				// Check if surplus is enough to settle liability
				for (const synonymousCurrency of this.exchangeService.getSynonyms(
					currency
				))
					try {
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
							{
								this.logger.debug(
									await this.exchangeService.trade(
										surplusCurrency,
										synonymousCurrency,
										amount
									)
								);
								return;
							}
						} else {
							this.logger.debug(
								'Did not have enough ' +
									surplusCurrency +
									' to buy ' +
									synonymousCurrency
							);
						}
					} catch (e) {
						this.logger.warn(e);
					}
			}
		}
		this.logger.warn('Could not make trade');
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

	async getFundsByRealName(): Promise<{
		[key: string]: { [key: string]: number };
	}> {
		const funds = await this.getFunds();
		return Object.keys(funds).reduce((acc, exchange) => {
			return {
				...acc,
				[exchange]: this.exchangeFundsToRealCurrency(funds[exchange]),
			};
		}, {});
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

	exchangeFundsToRealCurrency(i) {
		return Object.keys(i).reduce((acc, currency) => {
			acc[this.exchangeService.getRealName(currency)] =
				acc[currency] || 0;
			acc[this.exchangeService.getRealName(currency)] += i[currency];
			return acc;
		}, {});
	}

	async settle() {
		this.logger.verbose('Settling balances');
		const funds = await this.getTotalFunds();
		const liabilities = await this.getLiabilities();
		this.logger.verbose('Liabilities', liabilities, 'Funds', funds);
		for (const key of Object.keys(liabilities)) {
			if (liabilities[key] > funds[key]) {
				this.logger.log(key + ' funds lower than liabilities');
				await this.buy(key, liabilities[key] - funds[key]);
			}
		}
	}
}
