import { Inject, Injectable, Logger } from '@nestjs/common';
import { ActionTypeWithAmount, MSATOSHIS, TAddressType } from '@sudonym/models';
import {
	Network,
	validate as validateBitcoinAddress,
} from 'bitcoin-address-validation';
import * as bolt11 from 'bolt11';
import { Config } from 'config/config';
import { CurrencyService } from 'module/currency/currency.service';

@Injectable()
export class AddressParser {
	@Inject(CurrencyService) currencyService: CurrencyService;
	@Inject(Config) private readonly config: Config;
	private readonly logger = new Logger(AddressParser.name);

	async getBTCAmount(action: ActionTypeWithAmount): Promise<number> {
		return this.currencyService
			.convert(action.currency, 'BTC', action.amount)
			.then((e) => e.amount);
	}

	async getMSatAmount(action: ActionTypeWithAmount) {
		return this.getBTCAmount(action).then((i) => Math.round(i * MSATOSHIS));
	}

	getAddressType(originalAddress: string): [TAddressType, string] {
		this.logger.debug('Getting address type', originalAddress);

		// Trim whitespace and remove protocol and query
		let address = originalAddress.trim().replace(/(^\w+:|^)\/\//, '');
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
			const query = parseQuery(originalAddress.split('?').pop());
			if (query && query.lightning) {
				return this.getAddressType(query.lightning);
			}
			return ['onchain', address.split('?')[0]];
		}
		return [null, address];
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

export function parseQuery(queryString): any {
	const query = {};
	const pairs = (
		queryString[0] === '?' ? queryString.substr(1) : queryString
	).split('&');
	for (let i = 0; i < pairs.length; i++) {
		const pair = pairs[i].split('=');
		query[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1] || '');
	}
	return query;
}
