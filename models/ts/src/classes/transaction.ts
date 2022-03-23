export class Transaction {

    constructor(
        public id: string,
        public outgoing: boolean,
        public addressType: string,
        public address: string,
        public transactionId: string,
        public potId: string,
        public amount: number,
        public confirmed: boolean,
        public spendable: boolean,
        public OnchainTransactionId: string,
        public LightningInvoiceId: string,
        public createdAt: Date
    ) { }

    static fromJson(json: Object): Transaction {
        return new Transaction(
            json["id"],
            json["outgoing"],
            json["addressType"],
            json["address"],
            json["transactionId"],
            json["potId"],
            json["amount"],
            json["confirmed"],
            json["spendable"],
            json["OnchainTransactionId"],
            json["LightningInvoiceId"],
            json["createdAt"]
        );
    }
}