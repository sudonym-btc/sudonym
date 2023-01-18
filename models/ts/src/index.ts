export * from './api';
export * from './classes';
export * from './classes/types';

Object.defineProperty(Array.prototype, 'toList', {
	value: function () {
		return this;
	},
});
