export class Offer {

    constructor(
        public id: string,
        public potId: number,
        public active: boolean,
        public amount: number | null,
        public bolt12: string,
        public bolt12Unsigned: string,
    ) { }

    static fromJson(json: Object) {
        return new Offer(
            json["id"],
            json["potId"],
            json["active"],
            json["amount"],
            json["bolt12"],
            json["bolt12Unsigned"],
        );
    }
}