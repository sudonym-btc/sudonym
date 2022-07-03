export class TransactionSettlement {

    constructor(
        public id: number,
        public transactionId: number | null,
        public status: boolean | null,
        public createdAt: Date
    ) { }

    static fromJson(json: Object): TransactionSettlement {
        return new TransactionSettlement(
            json["id"],
            json["transactionId"],
            json["status"],
            json["createdAt"]
        );
    }
}