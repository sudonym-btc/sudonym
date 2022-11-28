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
			.subscribe(this.settle);
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

	async getFunds() {
		return {
			...(await this.exchangeService.listFunds()),
			lightning: {
				BTC: await this.lightningNodeService.listFunds(),
			},
		};
	}

	async settle() {
		this.logger.verbose('Settling balances');
		const funds = await this.getFunds();
		const liabilities = await this.getLiabilities();
		this.logger.verbose('Liabilities', liabilities, 'Funds', funds);
		for (const key of Object.keys(liabilities)) {
			const totalFunds = Object.values(funds).reduce((acc, i) => {
				return acc + i[key];
			}, 0);

			if (liabilities[key] > totalFunds) {
				this.logger.log(key + ' funds lower than liabilities');
			}
			await this.exchangeService.buy(liabilities[key], totalFunds);
		}
	}
}
