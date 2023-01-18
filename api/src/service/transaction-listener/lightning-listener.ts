import { Inject, Injectable, Logger } from '@nestjs/common';
import { MSATOSHIS } from '@sudonym/models';
import * as bolt11 from 'bolt11';
import { CurrencyService } from 'module/currency/currency.service';
import { skimDescription } from 'module/lightning/lnurl/lnurl-handler/lnurl-handler.service';
import { Transaction } from 'module/transaction/transaction.model';
import { Op } from 'sequelize';
import { LightningNodeService } from '../lightning-node/lightning-node.service';
import { LightningEvents, WaitSendPayResponse } from './lightning-events';
import { TransactionListener } from './transaction-listener.interface';

@Injectable()
export class LightningListener extends TransactionListener {
	private readonly logger = new Logger(LightningListener.name);

	@Inject() lightningNodeService: LightningNodeService;
	@Inject() lightningEvents: LightningEvents;
	@Inject() currencyService: CurrencyService;

	listenIncoming() {
		this.lightningEvents.onEvent.subscribe(async (event) => {
			if (
				event.event == 'invoice' &&
				event.data &&
				['paid', 'complete'].includes(event.data.status)
			) {
				const receivers = await this.receiveService.list({
					where: {
						data: event.data.bolt11,
					},
				});

				if (receivers.metadata.count) {
					let description = '';
					try {
						description = skimDescription(
							JSON.parse(event.data.description)
						);
					} catch (e) {
						description = event.data.description;
					}
					await this.transactionService.create({
						type: 'bolt11',
						originalAddress: receivers.data[0].data,
						address: receivers.data[0].data,
						potId: receivers.data[0].potId,
						receiverId: receivers.data[0].id,
						description: description,
						comment: receivers.data[0].comment,
						outgoing: false,
						amount:
							(event.data.msatoshi ||
								event.data.msatoshi_received) / //depends if amount in invoice as to which key to access
							MSATOSHIS,
						status: true,
						currencyCode: 'BTC',
						txid: event.data.payment_hash,
					});

					await this.receiveService.update(receivers.data[0].id, {
						received: receivers.data[0].received + 1,
					});
				}
			}
		});
	}

	async waitForPayment(payment_hash) {
		try {
			this.logger.debug('Waiting for payment hash', payment_hash);
			const pay = (
				await this.lightningNodeService.listPays(payment_hash)
			)[0];
			this.logger.debug('Pay', pay);

			const waitSendPay = async (partid) => {
				this.logger.debug('Waiting for sendpay', payment_hash, partid);
				this.lightningNodeService
					.waitSendPay(payment_hash, null, partid)
					.catch((e) => this.logger.error(e))
					.finally(() => this.waitForPayment(payment_hash));
			};

			if (pay.status == 'pending') {
				const sendpays = await this.lightningNodeService.listSendPays(
					null,
					payment_hash
				);

				const sendingPays = sendpays.filter(
					(s) => s.status === 'pending'
				);

				for (const sendpay of sendingPays) {
					waitSendPay(sendpay.partid);
				}

				if (!sendingPays.length) {
					this.logger.debug(
						'no inflight sendpays, so waiting for 2 seconds before recalling'
					);
					// Wait for payment
					setTimeout(() => {
						this.waitForPayment(payment_hash);
					}, 2000);
				}
			} else {
				this.lightningEvents.onEvent.next({
					event: 'sendpay',
					data: {
						payment_hash,
						...pay,
					} as WaitSendPayResponse,
				});
			}
		} catch (e) {
			this.logger.error(e);
		}
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
			this.logger.debug('Amount', btcAmount, btcAmount * MSATOSHIS);

			const response = this.lightningNodeService.pay(
				invoice,
				Math.ceil(btcAmount * MSATOSHIS)
			);
			response.finally(() => {
				this.waitForPayment(
					bolt11.decode(invoice).tagsObject.payment_hash
				);
			});
			await response;
		} catch (e) {
			this.logger.error('Pay error', e);
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
					this.waitForPayment(transaction.txid);
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
					txid: bolt11.decode(invoice).tagsObject.payment_hash,
				});

				this.triggerPayment(entity, invoice);
			}
		});

		this.lightningEvents.onEvent.subscribe(async (e) => {
			try {
				if (e.event == 'sendpay') {
					const transactions = await this.transactionService.list({
						where: {
							txid: e.data.payment_hash,
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
						totalAmount && amount
							? totalAmount - totalAmount
							: null;

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
			} catch (e) {
				this.logger.error(e);
			}
		});
	}
}
