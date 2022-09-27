import { Inject, Injectable, Logger } from '@nestjs/common';
import { LightningEvents } from './lightning-events';
import { MSATOSHIS } from '@sudonym/models';
import { TransactionService } from 'module/transaction/transaction.service';
import { TransactionListener } from './transaction-listener.interface';
import { LightningNodeService } from '../lightning-node/lightning-node.service';

@Injectable()
export class LightningListener extends TransactionListener {
	private readonly logger = new Logger(LightningListener.name);

	@Inject() lightningNodeService: LightningNodeService;
	@Inject() lightningEvents: LightningEvents;

	listenIncoming() {
		this.lightningEvents.onEvent.subscribe(async (e) => {
			if (e.event == 'invoice') {
				const receivers = await this.receiveService.list({
					where: {
						data: e.data.bolt11,
					},
				});

				if (receivers.metadata.count) {
					await this.transactionService.create({
						type: 'bolt11',
						originalAddress: receivers.data[0].data,
						address: receivers.data[0].data,
						potId: receivers.data[0].potId,
						receiverId: receivers.data[0].id,
						outgoing: false,
						amount: e.data.msatoshi / MSATOSHIS,
						status: true,
						currencyCode: 'BTC',
						txid: e.data.bolt11,
					});
				}
			}
		});
	}

	listenOutgoing() {
		this.transactionService.onAfterCreated.subscribe(
			async (transaction) => {
				this.logger.log(
					'Lightning outgoing: ',
					transaction.get({ plain: true })
				);
				if (
					transaction.outgoing &&
					['lnurl', 'lightningaddress', 'bolt11', 'bolt12'].includes(
						transaction.type
					)
				) {
					let bolt11;
					switch (transaction.type) {
						case 'bolt11':
							bolt11 = transaction.address;
							break;
						case 'bolt12':
							bolt11 =
								await this.lightningNodeService.fetchOfferInvoice(
									transaction.address
								);
							break;
						case 'lnurl':
						case 'lightningaddress':
							bolt11 = transaction.address;
							break;
					}
					await this.transactionService.update(transaction.id, {
						txid: bolt11,
					});

					// Attempt to trigger payment
					(async () => {
						try {
							await this.lightningNodeService.pay(bolt11);
							await this.lightningNodeService.rpc('waitsendpay', [
								bolt11,
							]);
						} catch (e) {
							console.error(e);
						}
					})();
				}
			}
		);

		this.lightningEvents.onEvent.subscribe(async (e: any) => {
			if (e.event == 'invoice') {
				const transactions = await this.transactionService.list({
					where: {
						txid: e.data.bolt11,
					},
				});
				if (transactions.metadata.count) {
					await this.transactionService.update(
						transactions.data[0].id,
						{
							status: true,
						}
					);
				}
			}
		});
	}
}
