export class ListState<T> {
	constructor(
		private data: T[],
		private metadata: {
			count: number;
		}
	) {}
}
