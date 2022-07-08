export class User {

    constructor(
        public id: String,
        public passHash: String,
        public firebaseId: String,
        public lightningAddress: String
    ) { }

    static fromJson(json: Object): User {
        return new User(json["id"], json["passHash"], json["firebaseId"], json["lightningAddress"]);
    }
}