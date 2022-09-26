import { Inject, Injectable, Logger } from '@nestjs/common';
import { TransactionService } from 'module/transaction/transaction.service';
import { TransactionListener } from './transaction-listener.interface';
import { BitcoinEvents } from './bitcoin-events';
import { LightningNodeService } from '../lightning-node/lightning-node.service';
import { SATOSHIS } from '@sudonym/models';
import { CurrencyService } from 'module/currency/currency.service';

@Injectable()
export class BitcoinListener extends TransactionListener {
	private readonly logger = new Logger(this.constructor.name);

	@Inject() lightningNodeService: LightningNodeService;
	@Inject() bitcoinEvents: BitcoinEvents;
	@Inject() transactionService: TransactionService;
	@Inject() currencyService: CurrencyService;

	listenIncoming() {
		this.bitcoinEvents.onTransaction.subscribe(async (e) => {
			for (const out of e.outs.filter((i) => i.address)) {
				const receivers = await this.receiveService.list({
					where: {
						data: out.address,
					},
				});

				if (receivers.metadata.count) {
					await this.transactionService.create({
						type: 'bolt11',
						originalAddress: out.fromAddress,
						address: receivers.data[0].data,
						potId: receivers.data[0].potId,
						receiverId: receivers.data[0].id,
						outgoing: false,
						amount: out.value / SATOSHIS,
						status: true,
						currencyCode: 'BTC',
						txid: out.address,
					});
				}
			}
		});
	}

	listenOutgoing() {
		this.transactionService.onAfterCreated.subscribe(
			async (transaction) => {
				this.logger.log(
					'Bitcoin outgoing: ',
					transaction.get({ plain: true })
				);
				if (
					transaction.outgoing &&
					['onchain'].includes(transaction.type)
				) {
					// Attempt to trigger payment
					(async () => {
						try {
							const btcAmount =
								await this.currencyService.convert(
									transaction.currencyCode,
									'BTC',
									transaction.amount
								);

							await this.lightningNodeService.withdrawOnChain({
								satoshis: btcAmount.amount * SATOSHIS,
								address: transaction.address,
							});
						} catch (e) {
							console.error(e);
						}
					})();
				}
			}
		);
	}
}
