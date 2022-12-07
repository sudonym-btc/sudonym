export class Event {
	constructor(public id: string | null, public name: string, public data) {}

	static fromJson(json: Object): Event {
		return new Event(json['id'], json['name'], json['data']);
	}

	toJson(): any {
		return {
			id: this.id,
			name: this.name,
			data: this.data,
		};
	}
}
