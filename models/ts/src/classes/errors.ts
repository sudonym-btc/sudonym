import * as CurrencyValueModel from './currency-value';

export class AppError extends Error {
	static staticCode = '';
	constructor() {
		super();
	}

	toString() {
		return AppError.staticCode;
	}
}

export class BalanceLowError extends AppError {
	static staticCode = 'BALANCE_LOW';
	code = BalanceLowError.staticCode;

	constructor(
		public amount: CurrencyValueModel.CurrencyValue,
		public amountLeft: CurrencyValueModel.CurrencyValue
	) {
		super();
	}

	static fromJson(json: Object): BalanceLowError {
		return new BalanceLowError(
			CurrencyValueModel.CurrencyValue.fromJson(json['amount']),
			CurrencyValueModel.CurrencyValue.fromJson(json['amountLeft'])
		);
	}

	toJson(): any {
		return {
			code: this.code,
			amount: this.amount.toJson(),
			amountLeft: this.amountLeft.toJson(),
		};
	}
	toString() {
		return BalanceLowError.staticCode;
	}
}

export class LNURLProtocolError extends AppError {
	static staticCode = 'LNURL_ERROR';
	code = LNURLProtocolError.staticCode;
	constructor(public data: string) {
		super();
	}

	static fromJson(json: Object): LNURLProtocolError {
		return new LNURLProtocolError(json['data']);
	}

	toJson(): any {
		return {
			code: this.code,
			data: this.data,
		};
	}

	toString() {
		return LNURLProtocolError.staticCode + ': ' + this.data;
	}
}

export const errors = {
	LNURLProtocolError,
	BalanceLowError,
};
