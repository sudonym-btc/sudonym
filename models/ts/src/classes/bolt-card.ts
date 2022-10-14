import { BaseClass } from './base-class';
import * as Model from './sender';

export class BoltCard extends BaseClass {
	constructor(
		public id: number | null,
		public userId: string | null,
		public senderId: number | null,
		public Sender: Model.Sender | null,
		public name: string | null,
		public written: number | null
	) {
		super();
	}

	static fromJson(json: Object): BoltCard {

		return new BoltCard(json['id'], json['userId'], json["senderId"], json["Sender"] != null ? Model.Sender.fromJson(json["Sender"]) : null, json['name'], json['written']);
	}

	toJson(): any {
		return {
			id: this.id,
			userId: this.userId,
			senderId: this.senderId,
			Sender: this.Sender != null ? this.Sender.toJson() : null,
			name: this.name,
			written: this.written
		};
	}
}
