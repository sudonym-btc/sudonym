import * as Factory from "factory.ts";
import { Pot } from "../classes/pot";

export const factory = Factory.Sync.makeFactory<Pot>({
    id: Factory.each(i => i.toString()),
    name: 'test pot',
    currency: 'BTC',
    balance: Math.random()
});
export const mocks = factory.buildList(20);