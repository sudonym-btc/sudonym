export class Callback<T> {
	callbacks = [];
	async execute(data: T) {
		for (const cb of this.callbacks) {
			await cb(data);
		}
	}
	listen(cb: (x: T) => void) {
		this.hook((x) => {
			cb(x);
		});
	}
	hook(cb: (x: T) => void) {
		this.callbacks.push(cb);
	}
}
