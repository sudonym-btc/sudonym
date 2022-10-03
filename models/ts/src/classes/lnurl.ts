import { WithdrawRequest } from "./withdraw-request";

export class Lnurl {
	constructor(
		public id: string,
		public params: WithdrawRequest | PaymentRequest
	) {}

	static fromJson(json: Object): Lnurl {
		return new Lnurl(
			json['id'],
			json['params']
		);
	}

	toJson(): any {
		return {
			id: this.id,
			params: this.params
		};
	}
}
