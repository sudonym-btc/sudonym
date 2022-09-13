export class Event {
	constructor(public name: string, public data) {}

	static fromJson(json: Object): Event {
		return new Event(json['name'], json['data']);
	}

	toJson(): any {
		return {
			name: this.name,
			data: this.data,
		};
	}
}
