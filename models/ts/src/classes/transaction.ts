export class Transaction {

    constructor(
        public id: number,
        public outgoing: boolean,
        public addressType: string | null,
        public address: string | null,
        public transactionId: string | null,
        public potId: string,
        public amount: number,
        public confirmed: boolean,
        public spendable: boolean,
        public OnchainTransactionId: string | null,
        public LightningInvoiceId: string | null,
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