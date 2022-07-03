export class Receiver {

    constructor(
        public id: number,
        public potId: number,
        public type: string,
        public amount: number,
        public amountCurrency: string,
        public data: string,
        public createdAt: Date
    ) { }

    static fromJson(json: Object): Receiver {
        return new Receiver(
            json["id"],
            json["potId"],
            json["type"],
            json["amount"],
            json["amountCurrency"],
            json["data"],
            json["createdAt"]
        );
    }
}