import { BaseClass } from './base-class';

export class PotUser extends BaseClass {
	constructor(
		public id: number,
		public potId: number,
		public userId: number
	) {
		super();
	}

	static fromJson(json: Object): PotUser {
		return new PotUser(json['id'], json['potId'], json['userId']);
	}

	toJson() {
		return {
			id: this.id,
			potId: this.potId,
			userId: this.userId,
		};
	}
}
