import { Inject, Injectable, Logger } from '@nestjs/common';
import { MSATOSHIS } from '@sudonym/models';
import {
	LightningError,
	LightningNodeService,
} from '../lightning-node/lightning-node.service';
import { LightningEvents } from './lightning-events';
import { TransactionListener } from './transaction-listener.interface';

@Injectable()
export class LightningListener extends TransactionListener {
	private readonly logger = new Logger(LightningListener.name);

	@Inject() lightningNodeService: LightningNodeService;
	@Inject() lightningEvents: LightningEvents;

	listenIncoming() {
		this.lightningEvents.onEvent.subscribe(async (e) => {
			if (
				e.event == 'invoice' &&
				e.data &&
				['paid', 'complete'].includes(e.data.status)
			) {
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
						amount:
							(e.data.msatoshi || e.data.msatoshi_received) / //depends if amount in invoice as to which key to access
							MSATOSHIS,
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

	async waitForPayment(payment_hash, invoice, partId) {
		if (!partId && payment_hash) {
			const sendpays = await this.lightningNodeService.listSendPays(
				null,
				payment_hash
			);
			this.logger.verbose('Sendpays', sendpays);
			partId = sendpays[0].partid;
		}
		this.logger.verbose('PartId', partId);

		const waitSendPay = async () => {
			this.logger.debug('Waiting for payment', invoice, payment_hash);
			await this.lightningNodeService
				.waitSendPay(payment_hash, null, partId)
				.then((e) => {
					if (e) {
						this.lightningEvents.onEvent.next({
							event: 'sendpay',
							data: {
								...e,
								bolt11: invoice,
								msatoshi: e.msatoshi_sent,
							},
						});
					}
					if (e.status == 'pending') {
						waitSendPay();
					}
				})
				.catch((e) => {
					if (e.error) {
						this.logger.error('Wait send pay error', e.error);
						if (e.error?.data) {
							this.lightningEvents.onEvent.next({
								event: 'sendpay',
								data: e.error.data,
							});
							if (e.error.data.status == 'pending') {
								waitSendPay();
							}
						}
					}
				});
		};

		waitSendPay();
	}

	async triggerPayment(entity, invoice) {
		// Attempt to trigger payment
		try {
			this.logger.debug(
				'Amount',
				entity.amount,
				entity.amount * MSATOSHIS
			);
			const response = await this.lightningNodeService.pay(
				invoice,
				Math.round(entity.amount * MSATOSHIS)
			);
			this.logger.debug('Lightning pay', response);
			this.waitForPayment(
				response.payment_hash,
				invoice,
				response.partid
			);
		} catch (e) {
			this.logger.error('Pay error', e);
			if (e instanceof LightningError) {
				this.logger.warn('Pay error', e);
				this.lightningEvents.onEvent.next({
					event: 'invoice',
					data: e.error.data,
				});
			}
		}
	}

	listenOutgoing() {
		this.transactionService.onAfterCreated.listen(async (entity) => {
			if (
				entity.outgoing &&
				['lnurl', 'lightningaddress', 'bolt11', 'bolt12'].includes(
					entity.type
				)
			) {
				this.logger.debug(
					'Lightning outgoing: ',
					entity.get({ plain: true })
				);
				let invoice;
				switch (entity.type) {
					case 'bolt11':
						invoice = entity.address;
						break;
					case 'bolt12':
						invoice =
							await this.lightningNodeService.fetchOfferInvoice(
								entity.address
							);
						break;
					case 'lnurl':
					case 'lightningaddress':
						invoice = entity.address;
						break;
				}
				await this.transactionService.update(entity.id, {
					txid: invoice,
				});

				this.triggerPayment(entity, invoice);
			}
		});

		this.lightningEvents.onEvent.subscribe(async (e) => {
			if (e.event == 'sendpay') {
				const transactions = await this.transactionService.list({
					where: {
						txid: e.data.bolt11,
						outgoing: true,
					},
				});

				const status =
					e.data.status == 'pending'
						? null
						: ['paid', 'complete'].includes(e.data.status)
						? true
						: false;

				if (transactions.metadata.count) {
					await this.transactionService.update(
						transactions.data[0].id,
						{
							totalAmount: (e.data as any).msatoshi_sent
								? (e.data as any).msatoshi_sent / MSATOSHIS
								: null,
							status,
							...(!status && (e.data as any).failcodename
								? {
										errorMessage: (e.data as any)
											.failcodename,
								  }
								: {}),
						}
					);
				}
			}
		});
	}
}
