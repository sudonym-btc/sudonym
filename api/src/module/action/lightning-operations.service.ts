import { Inject, Injectable, Logger } from '@nestjs/common';
import {
	Action,
	ActionRemoteResponse,
	ActionTypeWithAmount,
	MSATOSHIS,
} from '@sudonym/models';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { AddressParser } from './address-parser.service';

@Injectable()
export class LightningOperationsService {
	private readonly logger = new Logger(this.constructor.name);
	@Inject(LightningNodeService) lightningNodeService: LightningNodeService;
	@Inject(AddressParser) private addressParser: AddressParser;

	async parse(action: Action) {
		return Action.from({
			type: 'pay',
			isBolt11: true,
			remoteResponse: await this.fetchBolt11(action.originalAddress),
		});
	}

	async getInfo(action: ActionTypeWithAmount) {
		return Action.from({
			type: 'pay',
			isBolt11: true,
			remoteResponse: await this.fetchBolt11(action.originalAddress),
			fee: action.amount
				? (await this.lightningNodeService.getFeesInvoice(
						action.originalAddress,
						await this.addressParser.getMSatAmount(action)
				  )) / MSATOSHIS
				: null,
			feeCurrency: 'BTC',
		});
	}

	fetchBolt11 = async (invoice: string) => {
		try {
			// Decoded BOLT11 Invoice
			const data = await this.lightningNodeService.decodeInvoice(invoice);
			this.logger.log('decoded invoice', data);

			return ActionRemoteResponse.fromJson({
				data,
				message: null,
				success: true,
			}).toJson();
		} catch (e) {
			return {
				success: false,
				message: 'Could not parse lightning invoice',
				...e,
			};
		}
	};
}
