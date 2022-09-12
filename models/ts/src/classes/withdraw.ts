import { ActionType } from "./action-type";
import { ActionRemoteResponse } from "./action-remote-response";
import { WithdrawRequest } from "./withdraw-request";

export class Withdraw extends ActionType {

    constructor(
        public potId: number | null,
        public originalAddress: string,
        public currency: string | null,
        public amount: number | null,
        public minAmount: number | null,
        public maxAmount: number | null,
        public remoteResponse: ActionRemoteResponse<any>, // can't add withdrawrequest type here
    ) {
        super("withdraw", originalAddress);
    }

    static fromJson(json: Object): Withdraw {
        return new Withdraw(
            json["potId"],
            json["originalAddress"],
            json["currency"],
            json["amount"],
            json["minAmount"],
            json["maxAmount"],
            ActionRemoteResponse.fromJson(json["remoteResponse"])
        );
    }

    toJson() {
        return {
            potId: this.potId,
            originalAddress: this.originalAddress,
            currency: this.currency,
            amount: this.amount,
            minAmount: this.minAmount,
            maxAmount: this.maxAmount,
            remoteResponse: this.remoteResponse !== null ? this.remoteResponse.toJson() : null
        }
    }
}