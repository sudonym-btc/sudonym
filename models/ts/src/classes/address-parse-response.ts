export class AddressParseResponse {

    constructor(
        public originalInput: string | null,
        public success: boolean,
        public message: string | null,
        public data: any,
        public isLnUrl: boolean | null = false,
        public isLnAddress: boolean | null = false,
        public isBolt11: boolean | null = false,
        public isBolt12: boolean | null = false,
        public isOnChain: boolean | null = false,
    ) {

    }

    static fromJson(json: Object): AddressParseResponse {
        return new AddressParseResponse(
            json["originalInput"],
            json["success"],
            json["message"],
            json["data"],
            json["isLnUrl"],
            json["isLnAddress"],
            json["isBolt11"],
            json["isBolt12"],
            json["isOnChain"],
        );
    }
}