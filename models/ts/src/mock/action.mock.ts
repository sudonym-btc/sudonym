import faker from '@faker-js/faker';
import * as Factory from 'factory.ts';
import { Action } from '../classes/action';

export const factory = Factory.Sync.each<Action>(
	(i) =>
		({
			type: 'pay',
			originalAddress: 'shalom',
			isBolt11: false,
			isLnUrl: false,
			isLnAddress: false,
			isOnChain: false,
			isBolt12: false,
		} as Action)
);
export const mocks = factory.build(20);
