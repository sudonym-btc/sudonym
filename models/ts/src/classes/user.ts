export class User  {

    constructor(
        private id: String, 
        private firebaseId: String
    ) {}

    static fromJson(json: Object) {
        return new User(json["id"], json["firebaseId"]);
    }
}