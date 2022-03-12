export class Transaction {

    constructor(
        public id: string,
        public transactionId: string,
        public potId: string,
        public amount: number,
        public spendable: boolean,
        public OnchainTransactionId: string,
        public LightningInvoiceId: string,
        public createdAt: Date
    ) { }

    static fromJson(json: Object) {
        return new Transaction(
            json["id"],
            json["transactionId"],
            json["potId"],
            json["amount"],
            json["spendable"],
            json["OnchainTransactionId"],
            json["LightningInvoiceId"],
            json["createdAt"]
        );
    }
}