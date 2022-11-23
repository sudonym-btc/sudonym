import { HttpException, Inject, Injectable, Logger } from '@nestjs/common';
import {
	Action,
	ActionRemoteResponse,
	IAddressParser,
	TAddressType,
} from '@sudonym/models';
import { bech32 } from 'bech32';
import {
	Network,
	validate as validateBitcoinAddress,
} from 'bitcoin-address-validation';
import * as bolt11 from 'bolt11';
import { Buffer } from 'buffer';
import { Config } from 'config/config';
import fetch from 'node-fetch';
import { LightningNodeService } from '../../../service/lightning-node/lightning-node.service';
import { parseQuery } from '../action.service';
import { fetchHttpOpts } from './http-agent';

@Injectable()
export class AddressParser implements IAddressParser {
	@Inject(Config) private readonly config: Config;
	@Inject(LightningNodeService) lightningNodeService: LightningNodeService;
	private readonly logger = new Logger(AddressParser.name);

	async parse(address): Promise<Action> {
		const [type, trimmedAddress] = this.getType(address);
		this.logger.debug('Parsing', trimmedAddress, type);
		switch (type) {
			case 'lightningaddress': {
				return Action.from({
					originalAddress: trimmedAddress,
					type: 'pay',
					remoteResponse: await this.fetchRemoteLightningAddress(
						trimmedAddress
					),
					isLnUrl: true,
					isLnAddress: true,
				});
			}
			case 'lnurl': {
				const remoteResponse = await this.fetchRemoteLnUrl(
					trimmedAddress
				);
				return Action.from({
					originalAddress: trimmedAddress,
					type: remoteResponse.data.tag
						? remoteResponse.data.tag.replace('Request', '')
						: '',
					remoteResponse,
					isLnUrl: true,
				});
			}
			case 'onchain': {
				const query = parseQuery(address.split('?').pop());
				return Action.from({
					originalAddress: address,
					address: trimmedAddress,
					type: 'pay',
					minAmount: query.amount ? Number(query.amount) : null,
					amount: query.amount ? Number(query.amount) : null,
					currency: 'BTC',
					remoteResponse: await this.fetchOnChain(address),
					isOnChain: true,
				});
			}
			case 'bolt11': {
				return Action.from({
					originalAddress: trimmedAddress,
					type: 'pay',
					isBolt11: true,
					remoteResponse: await this.fetchBolt11(trimmedAddress),
				});
			}
		}
		throw new HttpException('Invalid address', 400);
	}

	fetchOnChain(address) {
		return {
			success: true,
		};
	}

	fetchRemoteLnUrl = async (invoice: string) => {
		const url = this.parseLnUrlString(invoice);

		this.logger.debug('Fetching LnUrl from ' + url);
		const data = await fetch(url, fetchHttpOpts)
			.then((r) => {
				return r.json();
			})
			.then((data) => {
				this.logger.debug('Fetched lnurl', data);
				return {
					success: data.statusCode
						? data.statusCode.toString().startsWith(2)
						: true,
					data,
				};
			})
			.catch((e) => {
				this.logger.error(e);
				return {
					success: false,
					message: e,
				};
			});
		return data;
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

	fetchBolt11 = async (invoice: string) => {
		console.log(invoice, invoice.includes(BOLT11_SCHEME));
		// Check if Invoice starts with `lnbc` prefix
		// if (!invoice.includes(BOLT11_SCHEME)) {
		// 	return null;
		// }
		try {
			this.logger.log('parsing');
			// Decoded BOLT11 Invoice
			const data = await this.lightningNodeService.decodeInvoice(invoice);
			this.logger.log(data);

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

	getType(address: string): [TAddressType, string] {
		this.logger.debug('Parsing', address);

		// Trim whitespace and remove protocol and query
		address = address.trim().replace(/(^\w+:|^)\/\//, '');
		if (!address || address === '') {
			return null;
		}

		// Check if Invoice has `lightning` or `lnurl` or bitcoin prefixes
		address = address.replace(LIGHTNING_SCHEME + ':', '');
		address = address.replace(LNURL_SCHEME + ':', '');
		address = address.replace(BITCOIN_SCHEME + ':', '');

		// Check if this is a Lightning Address
		if (validateInternetIdentifier(address)) {
			return ['lightningaddress', address.toLowerCase()];
		}

		try {
			bolt11.decode(address);
			return ['bolt11', address.toLowerCase()];
		} catch (e) {}

		if (
			address.toLowerCase().startsWith(LNURL_SCHEME) ||
			validURL('https://' + address)
		) {
			return ['lnurl', address.toLowerCase()];
		}
		if (
			validateBitcoinAddress(
				address.split('?')[0],
				['mock', 'development'].includes(this.config.env)
					? null
					: Network[this.config.bitcoin.network] // Don't check for valid network if in testing mode
			)
		) {
			return ['onchain', address.split('?')[0]];
		}
		return [null, address];
	}

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

export const validateInternetIdentifier = (internetIdentifier) => {
	const re = /\S+@\S+\.\S+/;
	return re.test(internetIdentifier);
};

export const validURL = (str) => {
	const res = str.match(
		/(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/g
	);
	return res !== null;
};

const LIGHTNING_SCHEME = 'lightning';
const BITCOIN_SCHEME = 'bitcoin';
const BOLT11_SCHEME = 'lnbc';
const LNURL_SCHEME = 'lnurl';
const BOLT12_SCHEME = 'lno1';
