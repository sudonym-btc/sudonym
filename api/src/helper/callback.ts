export class Callback<T> {
	callbacks = [];
	async execute(data: T) {
		try {
			for (const cb of this.callbacks) {
				await cb(data);
			}
		} catch (e) {

		}
	}
	listen(cb: (x: T) => void) {
		this.hook((x) => {
			try { cb(x) } catch (e) { console.error(e); };
		});
	}
	hook(cb: (x: T) => void) {
		this.callbacks.push(cb);
	}
}
