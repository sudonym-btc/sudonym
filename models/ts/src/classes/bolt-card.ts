import { BaseClass } from './base-class';

export class BoltCard extends BaseClass {
	constructor(
		public id: number | null,
		public userId: string | null,
		public senderId: number | null,
		public name: string | null,
		public data: string | null
	) {
		super();
	}

	static fromJson(json: Object): BoltCard {
		
		return new BoltCard(json['id'], json['userId'], json["senderId"], json['name'], json['data']);
	}

	toJson(): any {
		return {
			id: this.id,
			userId: this.userId,
			senderId: this.senderId,
			name: this.name,
			data: this.data
		};
	}
}
