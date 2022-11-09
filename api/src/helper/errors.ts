export class AppError extends Error {}

export class BalanceLowError extends AppError {
	name: 'BALANCE_LOW';
	data;
}
