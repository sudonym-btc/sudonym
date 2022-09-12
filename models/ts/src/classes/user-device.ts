import { BaseClass } from './base-class';

export class UserDevice extends BaseClass {

	constructor(
        public uid: string,
        public token: string
	) {
		super();
	}

	static fromJson(json: Object): UserDevice {
		return new UserDevice(json['uid'], json['token']);
	}

	toJson() {
		return {
			uid: this.uid,
			token: this.token,
		};
	}
}