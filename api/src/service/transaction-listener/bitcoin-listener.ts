import { Inject, Injectable } from '@nestjs/common';
import { TransactionService } from 'module/transaction/transaction.service';
import { TransactionListener } from './transaction-listener.interface';
import { BitcoinEvents } from './bitcoin-events';
import { LightningNodeService } from '../lightning-node/lightning-node.service';
import { SATOSHIS } from '@sudonym/models';

@Injectable()
export class BitcoinListener extends TransactionListener {
	@Inject() LightningNodeService: LightningNodeService;
	@Inject() bitcoinEvents: BitcoinEvents;
	@Inject() transactionService: TransactionService;

	listenIncoming() {
		this.bitcoinEvents.onTransaction.subscribe(async (e) => {
			for (const out of e.outs.filter(i => i.address)) {
				const receivers = await this.receiveService.list({
					where: {
						data: out.address,
					},
				});

				if (receivers.metadata.count) {
					await this.transactionService.create({
						type: 'bolt11',
						originalAddress: receivers.data[0].data,
						address: receivers.data[0].data,
						potId: receivers.data[0].potId,
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

	listenOutgoing() { }
}
