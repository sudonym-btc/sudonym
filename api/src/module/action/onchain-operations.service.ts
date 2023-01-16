import { Inject, Injectable, Logger } from '@nestjs/common';
import { Action, ActionParseResponse, SATOSHIS } from '@sudonym/models';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { AddressParser, parseQuery } from './address-parser.service';

@Injectable()
export class OnchainOperationsService {
	private readonly logger = new Logger(this.constructor.name);
	@Inject(LightningNodeService) lightningNodeService: LightningNodeService;
	@Inject(AddressParser) private addressParser: AddressParser;

	async parse(addr: string) {
		const fees = await this.lightningNodeService.onChainFees();
		const [type, trimmedAddress] = this.addressParser.getAddressType(addr);
		return Action.from({
			originalAddress: trimmedAddress,
			fee: fees.opening / SATOSHIS,
			feeCurrency: 'BTC',
		});
	}

	async getInfo(action: Action) {
		const query = parseQuery(action.originalAddress.split('?').pop());
		const [type, trimmedAddress] = this.addressParser.getAddressType(
			action.originalAddress
		);
		return Action.from({
			address: trimmedAddress,
			type: 'pay',
			minAmount: query.amount ? Number(query.amount) : null,
			amount: query.amount ? Number(query.amount) : null,
			currency: 'BTC',
			remoteResponses: [
				ActionParseResponse.from({
					success: true,
					data: {},
				}),
			],
			isOnChain: true,
		});
	}
}
