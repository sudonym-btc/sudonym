export class AppError extends Error {
	static code = '';
	constructor() {
		super();
	}
}

export class BalanceLowError extends AppError {
	static code = 'BALANCE_LOW';
	constructor(public data: string | null) {
		super();
	}
}

export class LNURLProtocolError extends AppError {
	static code = 'LNURL_ERROR';
	constructor(public data: string) {
		super();
	}
}

export const errors = {
	LNURLProtocolError,
	BalanceLowError,
};
