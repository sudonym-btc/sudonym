
export class PotUser {

    constructor(
        public id: number,
        public potId: number,
        public userId: number,
    ) { }

    static fromJson(json: Object): PotUser {
        return new PotUser(
            json["id"],
            json["potId"],
            json["userId"],
        );
    }
}