export class Payment {

    constructor(
        public originalAddress: string,
        public address: string | null,
        public amount: number | null,
        public feeMSat: number | null,
    ) { }

    static fromJson(json: Object): Payment {
        return new Payment(
            json["originalAddress"],
            json["address"],
            json["amount"],
            json["feeMSat"],
        );
    }
}