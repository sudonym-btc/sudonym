import { Inject, Injectable, Logger } from '@nestjs/common';
import { LightningEvents } from './lightning-events';
import { MSATOSHIS } from '@sudonym/models';
import { TransactionService } from 'module/transaction/transaction.service';
import { TransactionListener } from './transaction-listener.interface';
import { LightningNodeService } from '../lightning-node/lightning-node.service';
import * as bolt11 from 'bolt11';

@Injectable()
export class LightningListener extends TransactionListener {
	private readonly logger = new Logger(LightningListener.name);

	@Inject() lightningNodeService: LightningNodeService;
	@Inject() lightningEvents: LightningEvents;

	listenIncoming() {
		this.lightningEvents.onEvent.subscribe(async (e) => {
			if (e.event == 'invoice' && e.data.status == 'paid') {
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

					await this.receiveService.update(receivers.data[0].id, {
						received: receivers.data[0].received + 1,
					});
				}
			}
		});
	}

	listenOutgoing() {
		this.transactionService.onAfterCreated.subscribe(
			async (transaction) => {
				if (
					transaction.outgoing &&
					['lnurl', 'lightningaddress', 'bolt11', 'bolt12'].includes(
						transaction.type
					)
				) {
					this.logger.log(
						'Lightning outgoing: ',
						transaction.get({ plain: true })
					);
					let invoice;
					switch (transaction.type) {
						case 'bolt11':
							invoice = transaction.address;
							break;
						case 'bolt12':
							invoice =
								await this.lightningNodeService.fetchOfferInvoice(
									transaction.address
								);
							break;
						case 'lnurl':
						case 'lightningaddress':
							invoice = transaction.address;
							break;
					}
					await this.transactionService.update(transaction.id, {
						txid: invoice,
					});

					// Attempt to trigger payment
					(async () => {
						try {
							const response =
								await this.lightningNodeService.pay(invoice);
							// const obj = bolt11.decode(invoice);
							// const hash = obj.tags.find(t => t.tagName == "payment_hash").data;
							// console.log(obj);
							await this.lightningNodeService
								.rpc('waitsendpay', [response.payment_hash])
								.catch((e) => {
									if (e.response) {
										this.logger.warn(
											'Wait send pay error',
											e.response.data
										);
										this.lightningEvents.onEvent.next({
											event: 'invoice',
											data: e.response.data.error.data,
										});
										console.log('triggered');
									}
								});
						} catch (e) {
							console.error(e);
							if (e.response) {
								this.logger.warn(' Pay error', e.response.data);
								this.lightningEvents.onEvent.next({
									event: 'invoice',
									data: e.response.data.error.data,
								});
								console.log('triggered');
							}
						}
					})();
				}
			}
		);

		this.lightningEvents.onEvent.subscribe(async (e) => {
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
							status:
								e.data.status == 'pending'
									? null
									: e.data.status == 'paid'
									? true
									: false,
						}
					);
				}
			}
		});
	}
}
