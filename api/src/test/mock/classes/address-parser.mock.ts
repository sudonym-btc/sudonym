import { WithdrawRequest } from '@sudonym/models';
import { AddressParser } from 'module/action/address-parser/address-parser';

export class MockAddressParser extends AddressParser {
	fetchRemoteLnUrl = async (invoice: string) => {
		const parsedUrl = this.parseLnUrlString(invoice);
		if (parsedUrl.includes('lnurlw')) {
			return {
				success: true,
				data: {
					tag: 'withdrawRequest', // type of LNURL
					callback: parsedUrl, // The URL which LN SERVICE would accept a withdrawal Lightning invoice as query parameter
					k1: null, // Random or non-random string to identify the user's LN WALLET when using the callback URL
					defaultDescription: 'hi', // A default withdrawal invoice description
					minWithdrawable: 1000, // Min amount (in millisatoshis) the user can withdraw from LN SERVICE, or 0
					maxWithdrawable: 1000, // Max amount (in millisatoshis) the user can withdraw from LN SERVICE, or equal to minWithdrawable if the user has no choice over the amounts
				} as WithdrawRequest,
			};
		} else {
		}
	};
}
