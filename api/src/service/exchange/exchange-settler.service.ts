import { Inject, Injectable, Logger } from '@nestjs/common';
import { Config } from 'config/config';
import { SettlementService } from 'module/settlement/settlement.service';
import { debounceTime, merge, Subject, Subscription, timer } from 'rxjs';
import { PotService } from '../../module/pot/pot.service';
import { BalanceService } from './balance.service';
import { Exchange } from './exchange';
import { ExchangeService } from './exchange.service';

@Injectable()
export class ExchangeSettlerService {
	private readonly logger = new Logger(ExchangeSettlerService.name);

	@Inject() private readonly potService: PotService;
	@Inject() private readonly settlementService: SettlementService;
	@Inject() private readonly exchangeService: ExchangeService;
	@Inject() private readonly balanceService: BalanceService;
	@Inject() private readonly config: Config;

	exchanges: Exchange[] = [];
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

	async settle() {
		this.logger.debug('Settling balances');
		const funds = await this.balanceService.getTotalFunds();
		const liabilities = await this.balanceService.getLiabilities();
		this.logger.debug('Liabilities', liabilities, 'Funds', funds);
		for (const key of Object.keys(liabilities)) {
			if (liabilities[key] > (funds[key] || 0)) {
				this.logger.log(key + ' funds lower than liabilities');
				await this.exchangeService.buy(
					key,
					liabilities[key] - (funds[key] || 0)
				);
				// .then((order) => {
				// 	this.settlementService.create({
				// 		// fromCurrency: order.dfd
				// 	});
				// });
			}
		}
	}
}
