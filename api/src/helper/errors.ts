export class AppError extends Error {}

export class BalanceLowError extends AppError {
	name: 'BALANCE_LOW';
	data;
}

export class LNURLProtocolError extends AppError {
	// constructor(message) {
	// 	super(this.constructor.name, message);
	// }
	name: 'LNURL_ERROR';
	data;
}
