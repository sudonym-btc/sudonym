export type CurrencyCode = 'BTC' | 'USD' | 'GBP';
export const CurrencyCodes: string[] = ['BTC', 'USD', 'GBP'];

export class CurrencyResponse {
	constructor(public amount: number) { }
}

export const MSATOSHIS = 100000000000;
export const SATOSHIS = 100000000;
