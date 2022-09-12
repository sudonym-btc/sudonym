import { BaseClass } from "./base-class";

export class Pot extends BaseClass {

    constructor(
        public id: number,
        public name: string,
        public currency: string,
        public balance: number,
        public spendableBalance: number
    ) {
        super();
    }

    static fromJson(json: any): Pot {
        return new Pot(
            json["id"],
            json["name"],
            json["currency"],
            json["balance"],
            json["spendableBalance"]
        );
    }

    toJson() {
        return {
            id: this.id,
            name: this.name,
            currency: this.currency,
            balance: this.balance,
            spendableBalance: this.spendableBalance
        };
    }
}