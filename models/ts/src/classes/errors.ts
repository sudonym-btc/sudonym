export class AppError extends Error {
	static staticCode = '';
	constructor() {
		super();
	}
}

export class BalanceLowError extends AppError {
	static staticCode = 'BALANCE_LOW';
	code = BalanceLowError.staticCode;
	constructor() {
		super();
	}
}

export class LNURLProtocolError extends AppError {
	static staticCode = 'LNURL_ERROR';
	code = LNURLProtocolError.staticCode;
	constructor(public data: string) {
		super();
	}
}

export const errors = {
	LNURLProtocolError,
	BalanceLowError,
};
