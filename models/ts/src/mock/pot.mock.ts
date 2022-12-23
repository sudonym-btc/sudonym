import { faker } from '@faker-js/faker';
import * as Factory from 'factory.ts';
import { Pot } from '../classes/pot';
import { RecursivePartial } from '../recursive-partial';

export const factory = Factory.Sync.makeFactory<RecursivePartial<Pot>>({
	id: Factory.each((i) => i),
	name: Factory.each(
		(i) =>
			[
				'test pot',
				'savings',
				'holiday',
				'donations',
				'snacks',
				'cinema fund',
				'round up',
				'pet!',
			][i % 8]
	),
	currency: Factory.each((i) => faker.helpers.arrayElement(['BTC', 'USD'])),
	balance: Factory.each((i) => Math.random() * 10),
	spendableBalance: Factory.each((i) => Math.random() * 10),
	PotUser: Factory.each((i) => ({
		id: i,
		userId: '123',
		potId: i,
		index: i,
	})),
	PotUsers: Factory.each((i) => [
		{
			id: i,
			userId: '123',
			potId: i,
			index: i,
		},
	]),
});
export const mocks = factory.buildList(3);
