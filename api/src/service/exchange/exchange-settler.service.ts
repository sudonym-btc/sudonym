import { Inject, Injectable, Logger } from '@nestjs/common';
import { Config } from 'config/config';
import { Pot } from 'module/pot/pot.model';
import { debounceTime, merge, Subject, Subscription, timer } from 'rxjs';
import { Sequelize } from 'sequelize';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { PotService } from '../../module/pot/pot.service';
import { ExchangeService } from './exchange.service';

@Injectable()
export class ExchangeSettlerService {
	private readonly logger = new Logger(ExchangeSettlerService.name);

	@Inject() exchangeService: ExchangeService;
	@Inject() lightningNodeService: LightningNodeService;
	@Inject() potService: PotService;
	@Inject() config: Config;

	run = new Subject();
	subscription: Subscription;

	async listen() {
		if (this.subscription) this.subscription.unsubscribe();
		if (this.config.settle) {
			this.subscription = (
				this.config.intervalSettle
					? merge(this.run, timer(0, 10 * 60 * 1000))
					: this.run
			)
				.pipe(debounceTime(1000))
				.subscribe(this.settle.bind(this));
		}
	}

	async onApplicationBootstrap() {
		this.potService.onAfterUpdated.listen((entity) => {
			if (
				entity.changed('spendableBalance') ||
				entity.changed('balance')
			) {
				this.run.next(entity);
			}
		});

		this.config.onChanged.subscribe(this.listen.bind(this));

		// Run after application has started up
		setTimeout(() => {
			this.listen();
		}, 0);
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
		const totalFunds = await this.getTotalFunds();
		const liabilities = await this.getLiabilities();

		// For each exchange
		for (const exchange of Object.keys(exchangeFunds)) {
			// Check which currencies on this exchange we have more of than liabilties
			const surplusCurrencies = Object.keys(
				exchangeFunds[exchange]
			).filter(
				(i) =>
					totalFunds[this.exchangeService.getRealName(i)] >
					liabilities[this.exchangeService.getRealName(i)]
			);

			// For each surplus currency on the exchange
			for (const surplusCurrency of surplusCurrencies) {
				const surplusAmount =
					totalFunds[
						this.exchangeService.getRealName(surplusCurrency)
					] -
					(liabilities[
						this.exchangeService.getRealName(surplusCurrency)
					] || 0);

				// Check if surplus is enough to settle into any synonym of liability
				for (const synonymousCurrency of this.exchangeService.getSynonyms(
					currency
				)) {
					try {
						const surplusAmountInLiabilityCurrency =
							(await this.exchangeService.fetchPriceAtTime(
								surplusCurrency,
								synonymousCurrency
							)) *
							Math.min(
								exchangeFunds[exchange][surplusCurrency],
								surplusAmount
							);
						if (surplusAmountInLiabilityCurrency > amount) {
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
		this.logger.debug('Settling balances');
		const funds = await this.getTotalFunds();
		const liabilities = await this.getLiabilities();
		this.logger.debug('Liabilities', liabilities, 'Funds', funds);
		for (const key of Object.keys(liabilities)) {
			if (liabilities[key] > (funds[key] || 0)) {
				this.logger.log(key + ' funds lower than liabilities');
				await this.buy(key, liabilities[key] - (funds[key] || 0));
			}
		}
	}
}
