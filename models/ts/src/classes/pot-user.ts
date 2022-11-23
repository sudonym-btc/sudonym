import { BaseClass } from './base-class';

export class PotUser extends BaseClass {
	constructor(
		public id: number,
		public index: number,
		public potId: number,
		public userId: string
	) {
		super();
	}

	static fromJson(json: Object): PotUser {
		return new PotUser(
			json['id'],
			json['index'],
			json['potId'],
			json['userId']
		);
	}

	toJson(): any {
		return {
			id: this.id,
			index: this.index,
			potId: this.potId,
			userId: this.userId,
		};
	}
}
