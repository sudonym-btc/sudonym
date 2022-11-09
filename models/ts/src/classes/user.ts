import { BaseClass } from './base-class';
export const LIGHTNINGADDRESSREGEX = '^[a-z0-9_\\-\\.]+';
export class User extends BaseClass {
	constructor(
		public id: string,
		public firebaseId: string,
		public lightningAddress: string | null
	) {
		super();
	}

	static fromJson(json: Object): User {
		return new User(
			json['id'],
			json['firebaseId'],
			json['lightningAddress']
		);
	}

	toJson(): any {
		return {
			id: this.id,
			firebaseId: this.firebaseId,
			lightningAddress: this.lightningAddress,
		};
	}
}
