export class Transaction {

    constructor(
        private id: string,
        private transactionId: string,
        private potId: string,
        private OnchainTransactionId: string,
        private LightningTransactionId: string
    ) { }

    static fromJson(json: Object) {
        return new Transaction(
            json["id"],
            json["transactionId"],
            json["potId"],
            json["OnchainTransactionId"],
            json["LightningTransactionId"]
        );
    }
}