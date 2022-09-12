export class Event {

	constructor(
        public name: string,
        public data
	) { }

	static fromJson(json: Object): Event {
		return new Event(
			json['name'],
			json['data']
		);
	}

	toJson() {
		return {
			name: this.name,
			data: this.data
		};
	}
}