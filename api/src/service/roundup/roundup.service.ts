import { Inject, Injectable, Logger } from '@nestjs/common';
import { CurrencyService } from 'module/currency/currency.service';
import { Pot } from 'module/pot/pot.model';
import { PotService } from 'module/pot/pot.service';
import { TransactionService } from 'module/transaction/transaction.service';

@Injectable()
export class RoundupService {
	@Inject(CurrencyService) private currencyService: CurrencyService;
	@Inject(PotService) private potService: PotService;
	@Inject(TransactionService) private transactionService: TransactionService;
	private readonly logger = new Logger(this.constructor.name);

	onModuleInit() {
		console.log('Listening rounduop');
		this.transactionService.onAfterCreated.subscribe(
			async (transaction) => {
				console.log(transaction.outgoing);
				// Ignore incoming payments
				if (!transaction.outgoing) return;

				console.log('here');
				// Fetch roundup pots
				const pots = await Pot.findAll({
					where: {
						// userId: transaction.userId,
						// roundup: true,
					},
				});
				console.log(pots);

				const usd = await this.currencyService.convert(
					transaction.currencyCode,
					'USD',
					transaction.amount,
					transaction.createdAt
				);
				const leftOver = Math.ceil(usd.amount) - usd.amount;
				for (const pot of pots) {
					await this.transactionService.create({
						outgoing: false,
						amount: leftOver,
						currencyCode: 'USD',
						type: 'internal',
						potId: pot.id,
						transactionId: transaction.id,
					});
				}
			}
		);
	}
}
