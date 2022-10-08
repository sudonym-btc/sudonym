export class BaseClass {
	toJson(): any {
		return {};
	}

	static fromJson(json: any) {
		return new BaseClass();
	}
}
