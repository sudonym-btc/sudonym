import { ActionRemoteResponse } from './action-remote-response';
import { ActionTypeWithAmount } from './action-type';
import { MSATOSHIS, SATOSHIS } from './types/index';

export class Withdraw extends ActionTypeWithAmount {
	constructor(
		public potId: number | null,
		public originalAddress: string,
		public currency: string | null,
		public amount: number | null,
		public minAmount: number | null,
		public maxAmount: number | null,
		public remoteResponse: ActionRemoteResponse<any>, // can't add withdrawrequest type here
		public isLnUrl: boolean | null = false,
		public isLnAddress: boolean | null = false,
		public isBolt11: boolean | null = false,
		public isBolt12: boolean | null = false,
		public isOnChain: boolean | null = false,
		public comment: string | null = ''
	) {
		super(
			'withdraw',
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

	static fromJson(json: Object): Withdraw {
		const a = ActionRemoteResponse.fromJson(json['remoteResponse']);
		const w = new Withdraw(
			json['potId'],
			json['originalAddress'],
			json['currency'] != null ? json['currency'] : 'BTC',
			json['amount'],
			json['minAmount'] != null
				? json['minAmount']
				: a.success
				? a.data['minWithdrawable'] / MSATOSHIS
				: null,
			json['maxAmount'] != null
				? json['maxAmount']
				: a.success
				? a.data['maxWithdrawable'] / MSATOSHIS
				: null,
			a,
			json['isLnUrl'],
			json['isLnAddress'],
			json['isBolt11'],
			json['isBolt12'],
			json['isOnChain'],
			json['comment']
		);
		// Minimum value of 1 satoshi to withdraw
		w.minAmount = w.minAmount > 1 / SATOSHIS ? w.minAmount : 1 / SATOSHIS;
		if (w.amount == null && w.minAmount == w.maxAmount) {
			w.amount = w.minAmount;
		}

		return w;
	}

	toJson(): any {
		return {
			type: this.type,
			potId: this.potId,
			originalAddress: this.originalAddress,
			currency: this.currency,
			amount: this.amount,
			minAmount: this.minAmount,
			maxAmount: this.maxAmount,
			remoteResponse:
				this.remoteResponse !== null
					? this.remoteResponse.toJson()
					: null,
			comment: this.comment,
		};
	}
}
