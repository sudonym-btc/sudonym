import { LightningNodeService } from '../../../service/lightning-node/lightning-node.service';
import { bech32 } from 'bech32';
import { Buffer } from 'buffer';
import fetch from 'node-fetch';
import { Inject, Injectable, Logger } from '@nestjs/common';
import { IAddressParser, Action, ActionRemoteResponse } from '@sudonym/models';
import { fetchHttpOpts } from './http-agent';
import { Network, validate as validateBitcoinAddress } from 'bitcoin-address-validation';
import { Config } from 'config/config';

@Injectable()
export class AddressParser implements IAddressParser {
	@Inject(Config) private readonly config: Config;
	@Inject(LightningNodeService) lightningNodeService: LightningNodeService;
	private readonly logger = new Logger(AddressParser.name);

	async parse(address): Promise<Action> {
		const [type, trimmedAddress] = this.getType(address);
		switch (type) {
			case 'lightningaddress':
				return Action.from({
					originalAddress: trimmedAddress,
					type: 'pay',
					remoteResponse: await this.fetchRemoteLightningAddress(
						trimmedAddress
					),
					isLnUrl: true,
					isLnAddress: true,
				});
			case 'lnurl':
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
			case 'onchain':
				return Action.from({
					originalAddress: trimmedAddress,
					type: 'pay',
					remoteResponse: await this.fetchOnChain(trimmedAddress),
					isOnChain: true,
				});
			case 'bolt11':
				return Action.from({
					originalAddress: trimmedAddress,
					type: 'pay',
					isBolt11: true,
					remoteResponse: await this.fetchBolt11(trimmedAddress),
				});
		}
	}

	fetchOnChain(address) {
		return {
			succcess: true
		}
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
		// Check if Invoice starts with `lnbc` prefix
		if (!invoice.includes(BOLT11_SCHEME)) {
			return null;
		}

		// Decoded BOLT11 Invoice
		const data = await this.lightningNodeService.decodeInvoice(invoice);
		this.logger.debug(data);

		return ActionRemoteResponse.fromJson({
			data,
			message: null,
			success: true,
		}).toJson();
	};

	getType(address: string): [string, string] {
		// Trim whitespace and remove protocol
		address = address.trim().toLowerCase().replace(/(^\w+:|^)\/\//, '');
		if (!address || address === '') {
			return null;
		}

		// Check if this is a Lightning Address
		if (validateInternetIdentifier(address)) {
			return ['lightningaddress', address];
		}
		// Check if Invoice has `lightning` or `lnurl` prefixes
		// (9 chars + the `:` or `=` chars) --> 10 characters total
		const hasLightningPrefix = address.includes(`${LIGHTNING_SCHEME}:`);
		if (hasLightningPrefix) {
			// Remove the `lightning` prefix
			address = address.slice(10, address.length);
		}

		// (5 chars + the `:` or `=` chars) --> 6 characters total
		const hasLNURLPrefix = address.includes(`${LNURL_SCHEME}:`);
		if (hasLNURLPrefix) {
			// Remove the `lightning` prefix
			address = address.slice(6, address.length);
		}

		// Parse LNURL bech32 or URL, or BOLT11
		const isLnUrl = address.startsWith(LNURL_SCHEME) || validURL('https://' + address);
		return [isLnUrl ? 'lnurl' : validateBitcoinAddress(address, Network[this.config.bitcoin.network]) ? 'onchain' : 'bolt11', address];
	}

	parseLnUrlString(str: string) {
		if (str.includes('.')) {
			str = str
				.replace('lnurlw://', 'https://')
				.replace('lnurlp://', 'https://');

			if(!str.includes('https://')) {
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
	var res = str.match(/(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/g);
	return (res !== null)
}

const LIGHTNING_SCHEME = 'lightning';
const BOLT11_SCHEME = 'lnbc';
const LNURL_SCHEME = 'lnurl';
const BOLT12_SCHEME = 'lno1';
