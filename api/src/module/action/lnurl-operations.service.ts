import { Inject, Injectable, Logger } from '@nestjs/common';
import {
	Action,
	ActionRemoteResponse,
	LNURLProtocolError,
	MSATOSHIS,
	Payment,
	PaymentRequest,
	PaymentRequestCallback,
	PaymentRequestCallbackArgs,
	WithdrawRequest,
	WithdrawRequestCallbackArgs,
} from '@sudonym/models';
import axios from 'axios';
import { bech32 } from 'bech32';
import { skimDescription } from 'module/lightning/lnurl/lnurl-handler/lnurl-handler.service';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { AddressParser } from './address-parser.service';
import { fetchHttpOpts } from './http-agent';

@Injectable()
export class LnurlOperationsService {
	private readonly logger = new Logger(this.constructor.name);
	@Inject(AddressParser) private addressParser: AddressParser;
	@Inject(LightningNodeService) lightningNodeService: LightningNodeService;

	async parse(addr: string) {
		const [type, trimmedAddress] = this.addressParser.getAddressType(addr);
		const remoteResponse =
			type == 'lnurl'
				? await this.fetchRemoteLnUrl<PaymentRequest | WithdrawRequest>(
						trimmedAddress
				  )
				: await this.fetchRemoteLightningAddress<
						PaymentRequest | WithdrawRequest
				  >(trimmedAddress);
		return Action.from({
			originalAddress: trimmedAddress,
			type: remoteResponse.data.tag
				? remoteResponse.data.tag.replace('Request', '')
				: '',
			remoteResponses: [remoteResponse],
			isLnUrl: true,
			isLnAddress: type == 'lightningaddress',
		});
	}

	async getInfo(action: Action) {
		return action;
	}

	async execute(action: Payment) {
		const remoteResponse =
			await this.fetchRemoteLnUrl<PaymentRequestCallback>(
				(
					action.remoteResponses.at(
						0
					) as ActionRemoteResponse<PaymentRequest>
				).data.callback,
				{
					amount: await this.addressParser.getMSatAmount(action),
					...(action.comment != null && action.comment != ''
						? {
								comment: action.comment,
						  }
						: {}),
					payerData: JSON.stringify({
						name: 'Sudonym wallet', // free form string
						// "pubkey": string, // hex(<randomly generated secp256k1 pubkey>),
						// "auth": {
						//   "key": string, // hex(<linkingKey>)
						//   "k1": string, // same as received from service on section 1
						//   "sig": string, // following LUD-04: hex(sign(hexToBytes(<k1>), <linkingPrivKey>))
						// },
						// "email": string,
						// "identifier": string,
					}) as any,
				}
			);
		return Action.from({
			...action,
			remoteResponses: [...action.remoteResponses, remoteResponse],
			fee:
				(await this.lightningNodeService.getFeesInvoice(
					remoteResponse.data.pr,
					await this.addressParser.getMSatAmount(action)
				)) / MSATOSHIS,
			address: remoteResponse.data.pr,
			description:
				(await (
					await this.lightningNodeService.decodeInvoice(
						remoteResponse.data.pr
					)
				).tagsObject.description) ||
				(action.remoteResponses[0].data.metadata
					? skimDescription(action.remoteResponses[0].data.metadata)
					: null),
		});
	}

	fetchRemoteLnUrl = async <
		T = PaymentRequest | WithdrawRequest | PaymentRequestCallback
	>(
		address: string,
		params: PaymentRequestCallbackArgs | WithdrawRequestCallbackArgs = null
	): Promise<ActionRemoteResponse<T>> => {
		const url = this.parseLnUrlString(address);

		const u = new URL(url);
		for (const key in params) {
			u.searchParams.append(key, params[key]);
		}

		this.logger.debug('Fetching LnUrl from ' + u.toString());

		return await axios
			.get(u.toString(), fetchHttpOpts)
			.then((r) => {
				this.logger.log('Fetched lnurl', r.data);
				if (r.data.status == 'ERROR') {
					throw new LNURLProtocolError(r.data.reason);
				}
				if (!r.status.toString().startsWith('2')) {
					throw r;
				}
				return ActionRemoteResponse.fromJson({
					success: true,
					data: r.data,
				});
			})
			.catch((e) => {
				if (e.data?.status === 'ERROR') {
					throw new LNURLProtocolError(e.data.reason);
				}
				throw e;
			});
	};

	fetchRemoteLightningAddress = async <T>(
		internetIdentifier: string
	): Promise<ActionRemoteResponse<T>> => {
		const addressArr = internetIdentifier.split('@');

		// Must only have 2 fields (username and domain name)
		if (addressArr.length !== 2) {
			throw {
				success: false,
				message: 'Invalid internet identifier format.',
			};
		}

		const [username, domain] = addressArr;

		// Must only have 2 fields (username and domain name)
		if (!addressArr[1].includes('.')) {
			throw {
				success: false,
				message: 'Invalid internet identifier format.',
			};
		}

		const url = `https://${domain}/.well-known/lnurlp/${username}`;
		this.logger.debug('Fetching lnurl address', url);
		return this.fetchRemoteLnUrl(url)
			.then((d) => {
				return ActionRemoteResponse.fromJson({
					...d,
					data: {
						...d.data,
						domain,
						username,
					},
				});
			})
			.catch((e) => {
				if (e instanceof LNURLProtocolError) throw e;
				throw ActionRemoteResponse.fromJson({
					...e,
					success: false,
					message:
						'This identifier does not support Lightning Address yet.',
				});
			});
	};

	parseLnUrlString(str: string) {
		if (str.includes('.')) {
			str = str
				.replace('lnurlw://', 'https://')
				.replace('lnurlp://', 'https://');

			if (!str.includes('https://') && !str.includes('http://')) {
				str = 'https://' + str;
			}
			return str;
		} else {
			const decodedLNURL = bech32.decode(str, 1500);
			return Buffer.from(bech32.fromWords(decodedLNURL.words)).toString();
		}
	}
}
