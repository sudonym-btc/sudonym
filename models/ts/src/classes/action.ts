import { ActionType } from './action-type';
import { Payment } from './payment';
import { Withdraw } from './withdraw';

export class Action extends ActionType {
	constructor(
		public type: 'pay' | 'withdraw',
		public originalAddress: string,
		public isLnUrl: boolean | null = false,
		public isLnAddress: boolean | null = false,
		public isBolt11: boolean | null = false,
		public isBolt12: boolean | null = false,
		public isOnChain: boolean | null = false
	) {
		super(
			type,
			originalAddress,
			isLnUrl,
			isLnAddress,
			isBolt11,
			isBolt12,
			isOnChain
		);
	}

	static fromJson(json: Object): Action {
		return new Action(
			json['type'],
			json['originalAddress'],
			json['isLnUrl'],
			json['isLnAddress'],
			json['isBolt11'],
			json['isBolt12'],
			json['isOnChain']
		);
	}

	static from(json): Payment | Withdraw {		
		if (json['type'] == 'pay') return Payment.fromJson(json);
		return Withdraw.fromJson(json);
	}

	toJson(): any {
		return {
			type: this.type,
			originalAddress: this.originalAddress,
			isLnUrl: this.isLnUrl,
			isLnAddress: this.isLnAddress,
			isBolt11: this.isBolt11,
			isBolt12: this.isBolt12,
			isOnChain: this.isOnChain,
		};
	}
}
