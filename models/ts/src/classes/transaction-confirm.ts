export class TransactionConfirm {

    constructor(
        public feeMSat: number
    ) { }

    static fromJson(json: Object) {
        return new TransactionConfirm(
            json["feeMSat"]
        );
    }
}