import { ActionType } from './action-type';
import { ActionRemoteResponse } from './action-remote-response';
import { PaymentRequest } from './payment-request';
import { MSATOSHIS } from './types/index';

export class Payment extends ActionType {
	constructor(
		public potId: number | null,
		public originalAddress: string,
		public address: string | null,
		public currency: string | null,
		public amount: number | null,
		public minAmount: number | null,
		public maxAmount: number | null,
		public fee: number | null,
		public feeCurrency: string | null,
		public remoteResponse: ActionRemoteResponse<any>, // can't add paymentrequest type here
		public isLnUrl: boolean | null = false,
		public isLnAddress: boolean | null = false,
		public isBolt11: boolean | null = false,
		public isBolt12: boolean | null = false,
		public isOnChain: boolean | null = false,
		public comment: string | null = ''
	) {
		super(
			'pay',
			originalAddress,
			isLnUrl,
			isLnAddress,
			isBolt11,
			isBolt12,
			isOnChain,
			comment
		);
	}

	static fromJson(json: Object): Payment {
		const a = ActionRemoteResponse.fromJson(json['remoteResponse']);

		const p = new Payment(
			json['potId'],
			json['originalAddress'],
			json['address'],
			json['currency'],
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
			json['comment']
		);

		if (p.isBolt11) {
			if (p.remoteResponse.data['msatoshi'] != null) {
				p.minAmount = p.remoteResponse.data['msatoshi'] / MSATOSHIS;
				p.maxAmount = p.remoteResponse.data['msatoshi'] / MSATOSHIS;
			}
		} else if (p.isLnUrl) {
			if (p.remoteResponse.success) {
				p.minAmount = a.data['minSendable'] / MSATOSHIS;
				p.maxAmount = a.data['maxSendable'] / MSATOSHIS;
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
			remoteResponse:
				this.remoteResponse !== null
					? this.remoteResponse.toJson()
					: null,
			comment: this.comment,
		};
	}
}
