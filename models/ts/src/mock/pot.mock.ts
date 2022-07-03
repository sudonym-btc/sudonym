import faker from "@faker-js/faker";
import * as Factory from "factory.ts";
import { Pot } from "../classes/pot";

export const factory = Factory.Sync.makeFactory<Pot>({
    id: Factory.each(i => i),
    name: Factory.each(i => faker.helpers.arrayElement(['test pot', 'savings', 'holiday', 'donations'])),
    currency: Factory.each(i => faker.helpers.arrayElement(['BTC', 'USD'])),
    balance: Factory.each(i => Math.random() * 100000000),
    spendableBalance: Factory.each(i => Math.random() * 100000000)
});
export const mocks = factory.buildList(20);