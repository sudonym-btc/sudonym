export class User {

    constructor(
        public id: String,
        public firebaseId: String,
        public lightningAddress: String
    ) { }

    static fromJson(json: Object): User {
        return new User(json["id"], json["firebaseId"], json["lightningAddress"]);
    }
}