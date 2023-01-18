import { Inject, Injectable, Logger } from '@nestjs/common';
import {
	Action,
	ActionRemoteResponse,
	Payment,
	SATOSHIS,
} from '@sudonym/models';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { AddressParser, parseQuery } from './address-parser.service';

@Injectable()
export class OnchainOperationsService {
	execute(action: Payment) {
		return action;
	}
	private readonly logger = new Logger(this.constructor.name);
	@Inject(LightningNodeService) lightningNodeService: LightningNodeService;
	@Inject(AddressParser) private addressParser: AddressParser;

	async parse(addr: string) {
		const fees = await this.lightningNodeService.onChainFees();
		try {
			return Action.from({
				originalAddress: addr,
				type: 'pay',
				fee: fees.opening / SATOSHIS,
				feeCurrency: 'BTC',
				remoteResponses: [
					ActionRemoteResponse.fromJson({
						success: true,
						data: {},
					}),
				],
				isOnChain: true,
			});
		} catch (e) {
			console.error(e);
		}
	}

	async getInfo(action: Action) {
		const query = parseQuery(action.originalAddress.split('?').pop());
		const [type, trimmedAddress] = this.addressParser.getAddressType(
			action.originalAddress
		);
		return Action.from({
			address: trimmedAddress,
			minAmount: query.amount ? Number(query.amount) : null,
			amount: query.amount ? Number(query.amount) : null,
			currency: 'BTC',
			remoteResponses: [
				ActionRemoteResponse.fromJson({
					success: true,
					data: {},
				}),
			],
		});
	}
}
