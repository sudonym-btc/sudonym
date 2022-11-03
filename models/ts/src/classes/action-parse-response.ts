import { Withdraw } from './withdraw';
import { Payment } from './payment';

export class ActionParseResponse {
	constructor(
		public payment?: Payment | null,
		public withdraw?: Withdraw | null
	) {}

	static from(a: any) {
		switch (a['type']) {
			case 'pay':
				return new ActionParseResponse(Payment.fromJson(a), null);
			case 'withdraw':
				return new ActionParseResponse(null, Withdraw.fromJson(a));
		}
	}

	static fromJson(json: any) {
		if (json['payment'] != null) {
			return new ActionParseResponse(
				Payment.fromJson(json['payment']),
				null
			);
		} else if (json['withdraw'] != null) {
			return new ActionParseResponse(
				null,
				Withdraw.fromJson(json['withdraw'])
			);
		}
	}
}
