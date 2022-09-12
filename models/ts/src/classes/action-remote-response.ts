import { Bolt11 } from "./bolt11";
import { WithdrawRequest } from "./withdraw-request";
import { PaymentRequest } from "./payment-request";

type TT = Bolt11 | WithdrawRequest | PaymentRequest;

export class ActionRemoteResponse<T> {

    constructor(
        public success: boolean = true,
        public message: string | null,
        public data: T | null
    ) {

    }

    static fromJson(json: Object): ActionRemoteResponse<any> {
        return new ActionRemoteResponse(
            json["success"],
            json["message"],
            json["data"]
        );
    }

    toJson() {
        return {
            success: this.success,
            message: this.message,
            data: this.data
        }
    }
}