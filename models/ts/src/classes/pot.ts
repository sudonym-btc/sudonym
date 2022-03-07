
export class Pot {

    constructor(
        private id: string,
        private userId: string,
        private name: string,
        private currency: string,
        private balance: number
    ) { }

    static fromJson(json: Object) {
        return new Pot(
            json["id"], 
            json["userId"],
            json["name"], 
            json["currency"],
            json["balance"]
        );
    }
}