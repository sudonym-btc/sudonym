import faker from '@faker-js/faker';
import * as Factory from 'factory.ts';
import { RecursivePartial } from '../recursive-partial';
import { Transaction } from '../classes/transaction';

const addresses = [
	'paco@coincorner.io',
	'lnbc168gurn8ghj7ampd3kx2ar0veekzar0wd5xjtnrdakj7tnhv4kxctttdehhwm30d3h82unvwqhhwmm00fuhxar0wfjnywqetnxty',
	'lnurl1dp68gurn8ghj7ampd3kx2ar0veekzar0wd5xjtnrdakj7tnhv4kxctttdehhwm30d3h82unvwqhhwmm00fuhxar0wfjnywqetnxty',
	'myVFkhe2QzAzp4JqkBiCTK8n9vNhH2ZbPt',
];
const addressTypes = ['lightningaddress', 'bolt11', 'lnurl', 'onchain'];

export const factory = Factory.Sync.makeFactory<RecursivePartial<Transaction>>({
	id: Factory.each((i) => i),
	txid: Factory.each((i) => i.toString()),
	potId: Factory.each((i) => i),
	outgoing: Factory.each((i) => Boolean(Math.random() > 0.5)),
	description: Factory.each((i) =>
		faker.helpers.arrayElement([
			'Thanks for the drinks!',
			'www.payinbtc.com',
			'Chivo',
			'New bike',
		])
	),
	address: Factory.each((i) => addresses[addresses.length % i]),
	originalAddress: Factory.each((i) => addresses[addresses.length % i]),
	type: Factory.each((i) => addressTypes[addresses.length % i]),
	status: Factory.each(() => Boolean(Math.round(Math.random()))),
	transactionId: Factory.each((i) => i),
	amount: Factory.each(() => parseFloat((Math.random() * 2).toFixed(0))),
	currencyCode: Factory.each((i) => 'BTC'),
	createdAt: Factory.Sync.each(() => new Date()),
});
export const mocks = factory.buildList(20);
