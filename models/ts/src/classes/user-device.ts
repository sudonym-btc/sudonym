export class UserDevice {

    constructor(
        public uid: string,
        public token: string
    ) { }

    static fromJson(json: Object): UserDevice {
        return new UserDevice(json["uid"], json["token"]);
    }
}