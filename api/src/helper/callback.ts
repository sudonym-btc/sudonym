import { Subject } from 'rxjs';

export class Callback<T> extends Subject<T> {
	callbacks = [];
	async execute(data: T) {
		for (const cb of this.callbacks) {
			await cb(data);
		}
		this.next(data);
	}
	listen(cb: (x: T) => void) {
		this.hook(async (x) => {
			try {
				await cb(x);
			} catch (e) {
				console.error(e);
			}
		});
	}
	hook(cb: (x: T) => any) {
		this.callbacks.push(cb);
	}
}
