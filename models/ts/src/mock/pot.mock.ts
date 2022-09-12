import faker from '@faker-js/faker';
import * as Factory from 'factory.ts';
import { RecursivePartial } from 'index';
import { Pot } from '../classes/pot';

export const factory = Factory.Sync.makeFactory<RecursivePartial<Pot>>({
	id: Factory.each((i) => i),
	name: Factory.each((i) =>
		faker.helpers.arrayElement([
			'test pot',
			'savings',
			'holiday',
			'donations',
		])
	),
	currency: Factory.each((i) => faker.helpers.arrayElement(['BTC', 'USD'])),
	balance: Factory.each((i) => Math.random() * 10),
	spendableBalance: Factory.each((i) => Math.random() * 10),
});
export const mocks = factory.buildList(3);
