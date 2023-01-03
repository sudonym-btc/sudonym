import { Inject, Injectable, Logger } from '@nestjs/common';
import { MSATOSHIS } from '@sudonym/models';
import * as bolt11 from 'bolt11';
import { CurrencyService } from 'module/currency/currency.service';
import { Transaction } from 'module/transaction/transaction.model';
import { Op } from 'sequelize';
import {
	LightningError,
	LightningNodeService,
} from '../lightning-node/lightning-node.service';
import {
	LightningEvents,
	SendPayResponse,
	WaitSendPayResponse,
} from './lightning-events';
import { TransactionListener } from './transaction-listener.interface';

@Injectable()
export class LightningListener extends TransactionListener {
	private readonly logger = new Logger(LightningListener.name);

	@Inject() lightningNodeService: LightningNodeService;
	@Inject() lightningEvents: LightningEvents;
	@Inject() currencyService: CurrencyService;

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
						description:
							receivers.data[0].comment || e.data.description,
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
		if (payment_hash == null) {
			payment_hash = bolt11
				.decode(invoice)
				.tags.find((t) => t.tagName == 'payment_hash').data;
		}
		if (!partId && payment_hash) {
			const sendpays = await this.lightningNodeService.listSendPays(
				null,
				payment_hash
			);
			this.logger.verbose('Sendpays', sendpays);
			if (!sendpays.length) {
				this.lightningEvents.onEvent.next({
					event: 'sendpay',
					data: {
						bolt11: invoice,
						payment_hash,
						status: 'failed',
					} as WaitSendPayResponse,
				});
			}
			partId = sendpays[0].partid;
		}
		this.logger.verbose('PartId', partId);

		const waitSendPay = async () => {
			this.logger.debug(
				'Waiting for payment',
				invoice,
				payment_hash,
				partId
			);
			this.lightningNodeService
				.waitSendPay(payment_hash, null, partId)
				.then((e) => {
					if (e) {
						this.lightningEvents.onEvent.next({
							event: 'sendpay',
							data: {
								...e,
								bolt11: invoice,
							},
						});
					}
					if (e.status == 'pending') {
						waitSendPay();
					}
				})
				.catch((e) => {
					this.logger.error('Wait send pay error', e, e?.error);

					if (e.error) {
						// Old failed payments don't have the data key, as reason for failure not stored

						if (e.error?.data) {
							this.lightningEvents.onEvent.next({
								event: 'sendpay',
								data: {
									...e.error.data,
									bolt11: invoice,
								},
							});
							if (e.error.data.status == 'pending') {
								waitSendPay();
							}
						} else {
							this.lightningEvents.onEvent.next({
								event: 'sendpay',
								data: { ...e.error, bolt11: invoice },
							});
						}
					}
				});
		};

		waitSendPay();
	}

	async triggerPayment(entity: Transaction, invoice) {
		// Attempt to trigger payment
		try {
			this.logger.log(entity);
			const btcAmount = (
				await this.currencyService.convert(
					entity.currencyCode,
					'BTC',
					entity.amount,
					entity.createdAt
				)
			).amount;
			this.logger.log('Converted');
			this.logger.log(btcAmount);
			this.logger.debug('Amount', btcAmount, btcAmount * MSATOSHIS);
			const response = await this.lightningNodeService.pay(
				invoice,
				Math.round(btcAmount * MSATOSHIS)
			);
			this.logger.debug('Lightning pay', response);

			if (response.status) {
				this.lightningEvents.onEvent.next({
					event: 'sendpay',
					data: {
						bolt11: invoice,
						...response,
					} as unknown as WaitSendPayResponse,
				});
			}
			this.waitForPayment(
				response.payment_hash,
				invoice,
				(response as SendPayResponse).partid
			);
		} catch (e) {
			this.logger.error('Pay error', e);
			if (e instanceof LightningError) {
				this.logger.warn('Pay error', e);
				const data = e.error?.data || e.error;
				this.lightningEvents.onEvent.next({
					event: 'sendpay',
					data: {
						bolt11: invoice,
						...data,
						...(data.attempts?.length ? data.attempts[0] : {}),
					},
				});
			}
		}
	}

	listenOutgoing() {
		this.transactionService
			.list({
				where: {
					type: {
						[Op.in]: [
							'lnurl',
							'lightningaddress',
							'bolt11',
							'bolt12',
						],
					},
					status: null,
				},
			})
			.then((data) => {
				for (const transaction of data.data) {
					this.waitForPayment(null, transaction.txid, null);
				}
			});
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

				const errorMessage =
					e.data.failcodename ||
					e.data.failreason ||
					(e.data as any).message;
				const totalAmount = e.data.msatoshi_sent
					? e.data.msatoshi_sent / MSATOSHIS
					: null;
				const amount = e.data.msatoshi || e.data.amount_msat;
				const fee =
					totalAmount && amount ? totalAmount - totalAmount : null;

				if (transactions.metadata.count) {
					await this.transactionService.update(
						transactions.data[0].id,
						{
							totalAmount:
								totalAmount != null
									? totalAmount / MSATOSHIS
									: null,
							// fee: fee != null ? fee / MSATOSHIS : null,
							// feeCurrency: 'BTC',
							status,
							...(!status && errorMessage
								? {
										errorMessage,
								  }
								: {}),
						}
					);
				}
			}
		});
	}
}
