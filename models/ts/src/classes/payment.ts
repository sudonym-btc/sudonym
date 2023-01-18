import { ActionRemoteResponse } from './action-remote-response';
import { ActionTypeWithAmount } from './action-type';
import { MSATOSHIS, SATOSHIS } from './types/index';

export class Payment extends ActionTypeWithAmount {
	constructor(
		public potId: number | null,
		public originalAddress: string,
		public address: string | null,
		public currency: string | null,
		public amount: number | null,
		public minAmount: number | null,
		public maxAmount: number | null,
		public fee: number | null,
		public feeCurrency: string | null = 'BTC',
		public remoteResponses: ActionRemoteResponse<any>[] | any, // can't add paymentrequest type here
		public isLnUrl: boolean | null = false,
		public isLnAddress: boolean | null = false,
		public isBolt11: boolean | null = false,
		public isBolt12: boolean | null = false,
		public isOnChain: boolean | null = false,
		public comment: string | null = '',
		public description: string | null = '',
		public commentAllowed: number | null
	) {
		super(
			'pay',
			originalAddress,
			isLnUrl,
			isLnAddress,
			isBolt11,
			isBolt12,
			isOnChain,
			comment,
			minAmount,
			maxAmount,
			amount,
			currency
		);
	}

	static fromJson(json: Object): Payment {
		const a =
			json['remoteResponses'] != null
				? json['remoteResponses']
						.map((e) => ActionRemoteResponse.fromJson(e))
						.toList()
				: null;

		const p = new Payment(
			json['potId'],
			json['originalAddress'],
			json['address'],
			json['currency'] != null ? json['currency'] : 'BTC',
			json['amount'],
			json['minAmount'],
			json['maxAmount'],
			json['fee'],
			json['feeCurrency'],
			a,
			json['isLnUrl'],
			json['isLnAddress'],
			json['isBolt11'],
			json['isBolt12'],
			json['isOnChain'],
			json['comment'],
			json['description'],
			json['commentAllowed']
		);

		const remoteResponse = p.remoteResponses[p.remoteResponses.length - 1];

		if (remoteResponse != null) {
			if (p.isBolt11) {
				const sats =
					remoteResponse.data['satoshis'] != null
						? remoteResponse.data['satoshis']
						: remoteResponse.data['millisatoshis'] != null
						? remoteResponse.data['millisatoshis'] / 1000
						: null;
				if (sats != null) {
					p.minAmount = sats / SATOSHIS;
					p.maxAmount = sats / SATOSHIS;
				}
			} else if (p.isLnUrl) {
				if (remoteResponse.success) {
					p.minAmount =
						remoteResponse.data['minSendable'] / MSATOSHIS;
					p.maxAmount =
						remoteResponse.data['maxSendable'] / MSATOSHIS;
				}
			}
			// Minimum value of 1 satoshi to send
			p.minAmount =
				p.minAmount > 1 / SATOSHIS ? p.minAmount : 1 / SATOSHIS;
			if (p.amount == null && p.minAmount == p.maxAmount) {
				p.amount = p.minAmount;
			}
		}
		return p;
	}

	toJson(): any {
		return {
			type: this.type,
			potId: this.potId,
			originalAddress: this.originalAddress,
			address: this.address,
			currency: this.currency,
			amount: this.amount,
			minAmount: this.minAmount,
			maxAmount: this.maxAmount,
			fee: this.fee,
			feeCurrency: this.feeCurrency,
			remoteResponses:
				this.remoteResponses !== null
					? this.remoteResponses.map((e) => e.toJson()).toList()
					: null,
			comment: this.comment,
			description: this.description,
			commentAllowed: this.commentAllowed,
		};
	}
}
