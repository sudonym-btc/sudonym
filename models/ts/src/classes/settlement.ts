
export class Settlement {

    constructor(
        public id: number,
        public fromCurrency: string,
        public toCurrency: string,
        public exchangeId: string,
        public orderId: string,
        public status: boolean
    ) { }

    static fromJson(json: any): Settlement {
        return new Settlement(
            json["id"],
            json["fromCurrency"],
            json["toCurrency"],
            json["exchangeId"],
            json["orderId"],
            json["status"]
        );
    }

    toJson() {
        return {
            id: this.id,
            fromCurrency: this.fromCurrency,
            toCurrency: this.toCurrency,
            exchangeId: this.exchangeId,
            orderId: this.orderId,
            status: this.status
        }
    }
}