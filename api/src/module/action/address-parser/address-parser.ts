import { LightningNodeService } from '../../../service/lightning-node/lightning-node.service';
import { bech32 } from 'bech32';
import { Buffer } from 'buffer';
import fetch from 'node-fetch';
import { Inject, Injectable, Logger } from '@nestjs/common';
import { IAddressParser, Action } from '@sudonym/models';
import { fetchHttpOpts } from './http-agent';

@Injectable()
export class AddressParser implements IAddressParser {
	@Inject(LightningNodeService) lightningNodeService: LightningNodeService;
	private readonly logger = new Logger(AddressParser.name);

	async parse(address): Promise<Action> {
		const [type, trimmedAddress] = this.getType(address);

		switch (type) {
			case 'lightningaddress':
				return Action.from({
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
					type: remoteResponse.data.tag.replace('Request', ''),
					remoteResponse,
					isLnUrl: true,
				});
			case 'bolt11':
				return Action.from({
					type: 'pay',
					isBolt11: true,
					remoteResponse: await this.fetchBolt11(trimmedAddress),
				});
		}
	}

	fetchRemoteLnUrl = async (invoice: string) => {
		// Decoding bech32 LNURL
		const decodedLNURL = bech32.decode(invoice, 1500);
		const url = Buffer.from(
			bech32.fromWords(decodedLNURL.words)
		).toString();

		this.logger.debug('Fetching LnUrl from ' + url);
		const data = await fetch(url, fetchHttpOpts);
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
		const data = await fetch(url, fetchHttpOpts)
			.then((r) => r.json())
			.then((data) => {
				return {
					success: true,
					data: {
						...data,
						domain,
						username,
					},
				};
			})
			.catch((e) => {
				return {
					success: false,
					message:
						'This identifier does not support Lightning Address yet.',
				};
			});
		return data;
	};

	fetchBolt11 = async (invoice: string) => {
		// Check if Invoice starts with `lnbc` prefix
		if (!invoice.includes(BOLT11_SCHEME)) {
			return null;
		}

		// Decoded BOLT11 Invoice
		const result = await this.lightningNodeService.decodeInvoice(invoice);

		return result;
	};

	getType(address: string): [string, string] {
		address = address.trim().toLowerCase();
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

		// Parse LNURL or BOLT11
		const isLnUrl = address.startsWith(LNURL_SCHEME);

		return [isLnUrl ? 'lnurl' : 'bolt11', address];
	}
}

export const validateInternetIdentifier = (internetIdentifier) => {
	const re = /\S+@\S+\.\S+/;
	return re.test(internetIdentifier);
};

const LIGHTNING_SCHEME = 'lightning';
const BOLT11_SCHEME = 'lnbc';
const LNURL_SCHEME = 'lnurl';
const BOLT12_SCHEME = 'lno1';
