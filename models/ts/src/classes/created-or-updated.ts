export class CreatedOrUpdated<T> {
	constructor(
		public entity: T,
		public created: boolean,
		public changed: string[],
		public params: any
	) {}
}
