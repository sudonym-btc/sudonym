import { AddressParseResponse } from "./address-parse-response";

export class Payment {

    constructor(
        public potId: number | null,
        public originalAddress: string,
        public address: string | null,
        public amount: number | null,
        public minAmount: number | null,
        public maxAmount: number | null,
        public feeMSat: number | null,
        public addressParseResponse: AddressParseResponse,
    ) { }

    static fromJson(json: Object): Payment {
        return new Payment(
            json["potId"],
            json["originalAddress"],
            json["address"],
            json["amount"],
            json["minAmount"],
            json["maxAmount"],
            json["feeMSat"],
            AddressParseResponse.fromJson(json["AddressParseResponse"])
        );
    }
}