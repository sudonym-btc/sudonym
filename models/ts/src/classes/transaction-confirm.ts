export class TransactionConfirm {

    constructor(
        public name: string,
        public address: string,
        public feeMSat: number,
        public ContactId: number | null,
    ) { }

    static fromJson(json: Object): TransactionConfirm {
        return new TransactionConfirm(
            json["name"],
            json["address"],
            json["feeMSat"],
            json["ContactId"]
        );
    }
}