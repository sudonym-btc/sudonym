import { BaseClass } from './base-class';
import * as Model from './contact-address';
import * as PotModel from './pot';

export class Transaction extends BaseClass {
	constructor(
		public id: number,
		public onchainId: string | null,
		public invoiceId: string | null,
		public txid: string | null,
		public potId: number,
		public Pot: PotModel.Pot | null,
		public receiverId: number | null,
		public senderId: number | null,
		public outgoing: boolean,
		public type: string | null,
		public contactAddressId: number | null,
		public ContactAddress: Model.ContactAddress | null,
		public originalAddress: string | null,
		public address: string | null,
		public description: string | null,
		public transactionId: number | null,
		public amount: number,
		public totalAmount: number,
		public status: boolean | null,
		public errorMessage: string | null,
		public currencyCode: string,
		public createdAt: Date
	) {
		super();
	}

	static fromJson(json: Object): Transaction {
		return new Transaction(
			json['id'],
			json['onchainId'],
			json['invoiceId'],
			json['txid'],
			json['potId'],
			json['Pot'] != null ? PotModel.Pot.fromJson(json['Pot']) : null,
			json['receiverId'],
			json['senderId'],
			json['outgoing'],
			json['type'],
			json['contactAddressId'],
			json['ContactAddress'] != null
				? Model.ContactAddress.fromJson(json['ContactAddress'])
				: null,
			json['originalAddress'],
			json['address'],
			json['description'],
			json['transactionId'],
			json['amount'],
			json['totalAmount'],
			json['status'],
			json['errorMessage'],
			json['currencyCode'],
			json['createdAt']
		);
	}

	toJson(): any {
		return {
			id: this.id,
			onchainId: this.onchainId,
			invoiceId: this.invoiceId,
			txid: this.txid,
			potId: this.potId,
			Pot: this.Pot,
			receiverId: this.receiverId,
			senderId: this.senderId,
			outgoing: this.outgoing,
			type: this.type,
			contactAddressId: this.contactAddressId,
			ContactAddress: this.ContactAddress,
			originalAddress: this.originalAddress,
			address: this.address,
			description: this.description,
			transactionId: this.transactionId,
			amount: this.amount,
			totalAmount: this.amount,
			status: this.status,
			errorMessage: this.errorMessage,
			currencyCode: this.currencyCode,
			createdAt: this.createdAt,
		};
	}
}
