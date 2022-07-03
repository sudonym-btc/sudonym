
export class Pot {

    constructor(
        public id: number,
        public name: string,
        public currency: string,
        public balance: number,
        public spendableBalance: number
    ) { }

    static fromJson(json: Object): Pot {
        return new Pot(
            json["id"],
            json["name"],
            json["currency"],
            json["balance"],
            json["spendableBalance"]
        );
    }
}