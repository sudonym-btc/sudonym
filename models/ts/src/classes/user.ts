export class User  {

    constructor(
        public id: number, 
        public passHash: String,
        public firebaseId: String
    ) {}

    static fromJson(json: Object) {
        return new User(json["id"], json["passHash"], json["firebaseId"]);
    }
}