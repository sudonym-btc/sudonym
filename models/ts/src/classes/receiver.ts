export class Receiver {

    constructor(
        public id: string,
        public potId: string,
        public type: string,
        public amount: number,
        public data: string,
        public createdAt: Date
    ) { }

    static fromJson(json: Object) {
        return new Receiver(
            json["id"],
            json["potId"],
            json["type"],
            json["amount"],
            json["data"],
            json["createdAt"]
        );
    }
}