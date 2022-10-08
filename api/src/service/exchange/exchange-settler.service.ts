import { Inject, Injectable, Logger } from '@nestjs/common';
import { TransactionService } from '../../module/transaction/transaction.service';
import { PotService } from '../../module/pot/pot.service';
import { ExchangeService } from './exchange.service';

@Injectable()
export class ExchangeSettler {
	private readonly logger = new Logger(ExchangeSettler.name);

	@Inject() exchangeService: ExchangeService;
	@Inject() transactionService: TransactionService;
	@Inject() potService: PotService;

	async onModuleInit() {
		this.listenIncoming();
		this.listenOutgoing();
	}

	listenIncoming() {
		this.transactionService.onAfterCreated.subscribe(
			async (transaction) => {
				if (!transaction.outgoing) {
					const pot = await this.potService.findOne(
						transaction.potId
					);
					if (isBitcoin(transaction.type) && pot.currency != 'BTC') {
						await this.exchangeService.settle(
							'BTC',
							pot.currency,
							transaction.amount,
							'sell'
						);
					}
				}
			}
		);
	}

	listenOutgoing() {
		this.transactionService.onAfterCreated.subscribe(
			async (transaction) => {
				if (transaction.outgoing) {
					const pot = await this.potService.findOne(
						transaction.potId
					);
					if (isBitcoin(transaction.type) && pot.currency != 'BTC') {
						const order = await this.exchangeService.settle(
							'BTC',
							pot.currency,
							transaction.amount,
							'buy'
						);
					}
				}
			}
		);
	}
}

export const isBitcoin = (type) =>
	['lightningaddress', 'lnurl', 'bolt11', 'bolt12', 'onchain'].includes(type);
