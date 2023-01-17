import { Logger } from '@nestjs/common';
import { Subject } from 'rxjs';

export class Callback<T> extends Subject<T> {
	callbacks = [];
	private readonly logger = new Logger(this.constructor.name);

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
				this.logger.error(e);
			}
		});
	}
	hook(cb: (x: T) => any) {
		this.callbacks.push(cb);
	}
}
