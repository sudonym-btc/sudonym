
export class BaseClass {

	toJson() {
		return {};
	}

	static fromJson(json: any) {
		return new BaseClass();
	}
}