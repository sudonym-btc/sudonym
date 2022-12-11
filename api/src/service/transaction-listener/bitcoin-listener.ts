import { Inject, Injectable, Logger } from '@nestjs/common';
import { SATOSHIS } from '@sudonym/models';
import { CurrencyService } from 'module/currency/currency.service';
import { TransactionService } from 'module/transaction/transaction.service';
import { Op } from 'sequelize';
import { LightningNodeService } from '../lightning-node/lightning-node.service';
import { BitcoinEvents, BitcoinTransaction } from './bitcoin-events';
import { TransactionListener } from './transaction-listener.interface';

@Injectable()
export class BitcoinListener extends TransactionListener {
	private readonly logger = new Logger(this.constructor.name);

	@Inject() lightningNodeService: LightningNodeService;
	@Inject() bitcoinEvents: BitcoinEvents;
	@Inject() transactionService: TransactionService;
	@Inject() currencyService: CurrencyService;

	async checkTransactionsExists(txs: Partial<BitcoinTransaction>[]) {
		const addresses = txs
			.map((tx) =>
				tx.outs.filter((out) => out.address).map((out) => out.address)
			)
			.flat();

		const receivers = await this.receiveService.list({
			where: {
				[Op.or]: addresses.reduce(
					(acc, curr) => [
						...acc,
						{
							data: {
								[Op.like]: curr + '%',
							},
						},
					],
					[]
				),
			},
		});
		for (const receiver of receivers.data) {
			const getMatchedOuts = (tx) =>
				tx.outs.filter((out) => receiver.data.includes(out.address));
			const matchedTx = txs.find((tx) => getMatchedOuts(tx).length);

			if (
				(
					await this.transactionService.list({
						where: { txid: matchedTx.getId() },
					})
				).metadata.count
			) {
				// Already registered this transaction
				this.logger.warn(
					'Already have txid ' +
						matchedTx.getId() +
						' registered as transaction'
				);
				return;
			} else {
				await this.transactionService.create({
					type: 'onchain',
					originalAddress: matchedTx.outs.find(
						(out) => out.fromAddress
					)?.fromAddress,
					address: receivers.data[0].data,
					potId: receivers.data[0].potId,
					receiverId: receivers.data[0].id,
					outgoing: false,
					amount:
						getMatchedOuts(matchedTx).reduce(
							(acc, curr) => acc + curr.value,
							0
						) / SATOSHIS,
					status: null,
					currencyCode: 'BTC',
					txid: matchedTx.getId(),
				});
			}
		}
	}

	listenIncoming() {
		this.bitcoinEvents.onTransaction.subscribe((tx) =>
			this.checkTransactionsExists([tx])
		);

		// Confirmation when block confirmed

		this.bitcoinEvents.onBlock.subscribe(async (e) => {
			await this.checkTransactionsExists(e.transactions);
			for (const transaction of e.transactions) {
				const tx = await this.transactionService.list({
					where: {
						outgoing: false,
						txid: transaction.getId(),
					},
				});

				if (tx.metadata.count) {
					await this.transactionService.update(tx.data[0].id, {
						status: true,
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
					['onchain'].includes(transaction.type)
				) {
					// Attempt to trigger payment
					(async () => {
						this.logger.log(
							'Bitcoin outgoing: ',
							transaction.get({ plain: true })
						);
						try {
							const btcAmount =
								await this.currencyService.convert(
									transaction.currencyCode,
									'BTC',
									transaction.amount
								);

							const response =
								await this.lightningNodeService.withdrawOnChain(
									{
										satoshis: btcAmount.amount * SATOSHIS,
										address: transaction.address,
									}
								);
							await this.transactionService.update(
								transaction.id,
								{
									txid: response.txid,
									status: true,
								}
							);
						} catch (e) {
							await this.transactionService.update(
								transaction.id,
								{
									status: false,
									errorMessage: e.toString(),
								}
							);
						}
					})();
				}
			}
		);
	}
}
