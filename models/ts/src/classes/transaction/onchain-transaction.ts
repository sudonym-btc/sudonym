export abstract class OnchainTransaction {
    fromAddress: string;
    toAddress: string;
    amount: string;
    data: JSON;
}