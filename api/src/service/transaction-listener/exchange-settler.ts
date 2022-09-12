import { Inject, Injectable, Logger } from '@nestjs/common';
import { TransactionService } from '../../module/transaction/transaction.service';
import * as ccxt from 'ccxt';
import * as fs from 'fs';
import { PotService } from '../../module/pot/pot.service';
import { SettlementService } from '../..//module/settlement/settlement.service';

@Injectable()
export class ExchangeSettler {
	private readonly logger = new Logger(ExchangeSettler.name);

	@Inject() settlementService: SettlementService;
	@Inject() transactionService: TransactionService;
	@Inject() potService: PotService;

	exchanges: ccxt.Exchange[] = [];

	async onModuleInit() {
		this.exchanges = fs
			.readdirSync('src/exchanges')
			.filter((f) => f.includes('.json'))
			.map((f) => {
				return new ccxt[f.split('.')[0]](
					JSON.parse(
						fs.readFileSync('src/exchanges/' + f, {
							encoding: 'utf8',
						})
					)
				);
			});

		for (const exchange of this.exchanges) {
			await exchange.fetchMarkets();
		}

		this.listenIncoming();
		this.listenOutgoing();
	}

	listenIncoming() {
		this.transactionService.onAfterCreated.listen(async (transaction) => {
			if (!transaction.outgoing) {
				const pot = await this.potService.findOne(transaction.potId);
				if (isBitcoin(transaction.type) && pot.currency != 'BTC') {
					this.createSettlement(
						[transaction],
						'BTC',
						pot.currency,
						transaction.amount,
						'sell'
					);
				}
			}
		});
	}

	listenOutgoing() {
		this.transactionService.onAfterCreated.listen(async (transaction) => {
			if (transaction.outgoing) {
				const pot = await this.potService.findOne(transaction.potId);
				if (isBitcoin(transaction.type) && pot.currency != 'BTC') {
					this.createSettlement(
						[transaction],
						'BTC',
						pot.currency,
						transaction.amount,
						'buy'
					);
				}
			}
		});
	}

	async createSettlement(transactions, from, to, amount, side) {
		const markets = await this.exchanges[0].fetchMarkets();
		const market = markets.find(
			(m) =>
				(m.baseId == from && m.quoteId == to) ||
				(m.baseId == to && m.quoteId == from)
		);
		// console.log(market);
		await this.exchanges[0]
			.createMarketOrder(
				market.symbol,
				market.baseId == from ? side : side == 'buy' ? 'sell' : side,
				amount
			)
			.then(async (order) => {
				await this.settlementService.create({
					exchangeId: this.exchanges[0].name,
					fromCurrency: from,
					toCurrency: to,
					amount: amount,
					orderId: order.id,
				});
			});
	}
}

export const isBitcoin = (type) =>
	['lightningaddress', 'lnurl', 'bolt11', 'bolt12', 'onchain'].includes(type);
