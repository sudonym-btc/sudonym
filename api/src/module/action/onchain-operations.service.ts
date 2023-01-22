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
		const query = parseQuery(addr.split('?').pop());
		const [type, trimmedAddress] = this.addressParser.getAddressType(addr);

		try {
			return Action.from({
				originalAddress: addr,
				address: trimmedAddress,
				type: 'pay',
				minAmount: query.amount ? Number(query.amount) : null,
				amount: query.amount ? Number(query.amount) : null,
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
		return Action.from({
			...action,
			remoteResponses: [
				ActionRemoteResponse.fromJson({
					success: true,
					data: {},
				}),
			],
		});
	}
}
