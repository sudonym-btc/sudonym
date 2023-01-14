import { Inject, Injectable, Logger } from '@nestjs/common';
import {
	Action,
	ActionRemoteResponse,
	MSATOSHIS,
	Payment,
} from '@sudonym/models';
import axios from 'axios';
import { bech32 } from 'bech32';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { AddressParser } from './address-parser.service';
import { fetchHttpOpts } from './http-agent';

@Injectable()
export class LnurlOperationsService {
	private readonly logger = new Logger(this.constructor.name);
	@Inject(AddressParser) private addressParser: AddressParser;
	@Inject(LightningNodeService) lightningNodeService: LightningNodeService;

	async parse(action: Action) {
		const [type, trimmedAddress] = this.addressParser.getAddressType(
			action.originalAddress
		);
		const remoteResponse =
			type == 'lnurl'
				? await this.fetchRemoteLnUrl(trimmedAddress)
				: await this.fetchRemoteLightningAddress(trimmedAddress);
		return Action.from({
			originalAddress: trimmedAddress,
			type: remoteResponse.data.tag
				? remoteResponse.data.tag.replace('Request', '')
				: '',
			remoteResponse,
			isLnUrl: true,
			isLnAddress: type == 'lightningaddress',
		});
	}

	async getInfo(action: Action) {
		if (action instanceof Payment) {
			const remoteResponse = await this.fetchRemoteLnUrl(
				action.remoteResponse.data as any,
				{
					amount: await this.addressParser.getMSatAmount(action),
					comment: action.comment,
					payerData: {
						name: 'Sudonym wallet', // free form string
						// "pubkey": string, // hex(<randomly generated secp256k1 pubkey>),
						// "auth": {
						//   "key": string, // hex(<linkingKey>)
						//   "k1": string, // same as received from service on section 1
						//   "sig": string, // following LUD-04: hex(sign(hexToBytes(<k1>), <linkingPrivKey>))
						// },
						// "email": string,
						// "identifier": string,
					},
				}
			);
			return Action.from({
				...action,
				remoteResponse,
				fee:
					(await this.lightningNodeService.getFeesInvoice(
						remoteResponse.data.pr,
						await this.addressParser.getMSatAmount(action)
					)) / MSATOSHIS,
				address: remoteResponse.data.pr,
				description: await (
					await this.lightningNodeService.decodeInvoice(
						remoteResponse.data.pr
					)
				).tagsObject.description,
			});
		}

		return action;
	}

	fetchRemoteLnUrl = async (
		address: string,
		params = null
	): Promise<ActionRemoteResponse<any>> => {
		const url = this.parseLnUrlString(address);

		const u = new URL(url);
		for (const key in params) {
			u.searchParams.append(key, params[key]);
		}
		this.logger.debug('Getting callback ', u.toString());

		this.logger.debug('Fetching LnUrl from ' + url);
		const data = await axios(u.toString(), fetchHttpOpts)
			.then(async (r) => {
				this.logger.debug('Fetched lnurl', r.data);

				return {
					success: r.status
						? r.status.toString().startsWith('2')
						: true, // todo: Why returning true here
					data: r.data,
				};
			})
			.catch((e) => {
				this.logger.error(e);
				return {
					success: false,
					message: e,
				};
			});
		return ActionRemoteResponse.fromJson(data);
	};

	fetchRemoteLightningAddress = async (internetIdentifier: string) => {
		const addressArr = internetIdentifier.split('@');

		// Must only have 2 fields (username and domain name)
		if (addressArr.length !== 2) {
			return {
				success: false,
				message: 'Invalid internet identifier format.',
			};
		}

		const [username, domain] = addressArr;

		// Must only have 2 fields (username and domain name)
		if (!addressArr[1].includes('.')) {
			return {
				success: false,
				message: 'Invalid internet identifier format.',
			};
		}

		const url = `https://${domain}/.well-known/lnurlp/${username}`;
		this.logger.debug('Fetching lnurl address', url);
		return this.fetchRemoteLnUrl(url)
			.then((d) => {
				if (d.success == false) {
					throw d;
				}
				return {
					...d,
					data: {
						...d.data,
						domain,
						username,
					},
				};
			})
			.catch((d) => {
				return {
					...d,
					message:
						'This identifier does not support Lightning Address yet.',
				};
			});
	};

	parseLnUrlString(str: string) {
		if (str.includes('.')) {
			str = str
				.replace('lnurlw://', 'https://')
				.replace('lnurlp://', 'https://');

			if (!str.includes('https://')) {
				str = 'https://' + str;
			}
			return str;
		} else {
			const decodedLNURL = bech32.decode(str, 1500);
			return Buffer.from(bech32.fromWords(decodedLNURL.words)).toString();
		}
	}
}
