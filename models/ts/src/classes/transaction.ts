
export class Transaction {

    constructor(
        public id: number,
        public txid: string | null,
        public potId: number,
        public outgoing: boolean,
        public type: string | null,
        public originalAddress: string | null,
        public address: string | null,
        public description: string | null,
        public transactionId: number | null,
        public amount: number,
        public status: boolean | null,
        public currencyCode: string,
        public createdAt: Date
    ) { }

    static fromJson(json: Object): Transaction {
        return new Transaction(
            json["id"],
            json["txid"],
            json["potId"],
            json["outgoing"],
            json["type"],
            json["originalAddress"],
            json["address"],
            json["description"],
            json["transactionId"],
            json["amount"],
            json["status"],
            json["currencyCode"],
            json["createdAt"]
        );
    }
}