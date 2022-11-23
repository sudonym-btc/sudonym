import * as Factory from 'factory.ts';
import { PotUser } from '../classes/pot-user';
import { RecursivePartial } from '../recursive-partial';

export const factory = Factory.Sync.makeFactory<RecursivePartial<PotUser>>({
	id: Factory.each((i) => i),
	index: Factory.each((i) => i),
	potId: Factory.each((i) => i),
	userId: '123',
});
export const mocks = factory.buildList(3);
