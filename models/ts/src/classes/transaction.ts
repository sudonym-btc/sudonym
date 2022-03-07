export class Transaction {

    constructor(
        private id: string,
        private transactionId: string,
        private potId: string,
        private amount: number,
        private OnchainTransactionId: string,
        private LightningTransactionId: string,
        private createdAt: Date
    ) { }

    static fromJson(json: Object) {
        return new Transaction(
            json["id"],
            json["transactionId"],
            json["potId"],
            json["amount"],
            json["OnchainTransactionId"],
            json["LightningTransactionId"],
            json["createdAt"]
        );
    }
}