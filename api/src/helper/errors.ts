export class AppError {}

export class BalanceLowError extends AppError {
    code: 'BALANCE_LOW'
    data
}