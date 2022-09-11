import { ActionType } from "./action-type";
import { ActionRemoteResponse } from "./action-remote-response";
import { PaymentRequest } from "./payment-request";

export class Payment extends ActionType {

    constructor(
        public potId: number | null,
        public originalAddress: string,
        public address: string | null,
        public currency: string | null,
        public amount: number | null,
        public minAmount: number | null,
        public maxAmount: number | null,
        public fee: number | null,
        public remoteResponse: ActionRemoteResponse<any>, // can't add paymentrequest type here
    ) {
        super("pay", originalAddress);
    }

    static fromJson(json: Object): Payment {
        return new Payment(
            json["potId"],
            json["originalAddress"],
            json["address"],
            json["currency"],
            json["amount"],
            json["minAmount"],
            json["maxAmount"],
            json["fee"],
            ActionRemoteResponse.fromJson(json["remoteResponse"])
        );
    }
}