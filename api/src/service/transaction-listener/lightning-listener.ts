import { Inject, Injectable, Logger } from '@nestjs/common';
import { LightningEvents } from './lightning-events';
import { Bolt11Received, MSATOSHIS } from '@sudonym/models';
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
			if (e.event == 'invoice' && e.data && ['paid', 'complete'].includes(e.data.status)) {
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
							this.logger.debug('Lightning pay', response);
							let partId = !isNaN(response.partid) ? response.partid : undefined;
							this.logger.debug('PartId', partId);
							if (!partId && response.bolt11) {
								const sendpays = (await this.lightningNodeService.rpc('listsendpays', response.bolt11)).payments;
								partId = sendpays[0].partid;
							}
							await this.lightningNodeService
								.rpc('waitsendpay', [response.payment_hash, 1000, partId])
								.catch((e) => {
									if (e.response) {
										this.logger.error(
											'Wait send pay error',
											e.response.data
										);
										if (e.response.data?.error?.data) {
											this.lightningEvents.onEvent.next({
												event: 'invoice',
												data: e.response.data.error.data,
											});
										}
									}
								}).then(e => {
									this.logger.debug(e);
									if (e) {
										this.lightningEvents.onEvent.next({
											event: 'sendpay',
											data: {
												...e,
												bolt11: invoice,
												msatoshi: e.msatoshi_sent
											}
										});
									}
								});
						} catch (e) {
							this.logger.error(
								'Pay error', e);
							if (e.response) {
								this.logger.warn('Pay error', e.response.data);
								this.lightningEvents.onEvent.next({
									event: 'invoice',
									data: e.response.data.error.data,
								});
							}
						}
					})();
				}
			}
		);

		this.lightningEvents.onEvent.subscribe(async (e) => {
			this.logger.log('Lightning event in listener', e);
			if (e.event == 'sendpay') {
				const transactions = await this.transactionService.list({
					where: {
						txid: e.data.bolt11,
						outgoing: true
					},
				});
				if (transactions.metadata.count) {
					await this.transactionService.update(
						transactions.data[0].id,
						{
							status:
								e.data.status == 'pending'
									? null
									: ['paid', 'complete'].includes(e.data.status)
										? true
										: false,
						}
					);
				}
			}
		});
	}
}
