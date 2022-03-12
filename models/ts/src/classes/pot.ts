
export class Pot {

    constructor(
        public id: string,
        public name: string,
        public currency: string,
        public balance: number
    ) { }

    static fromJson(json: Object) {
        return new Pot(
            json["id"], 
            json["name"], 
            json["currency"],
            json["balance"]
        );
    }
}