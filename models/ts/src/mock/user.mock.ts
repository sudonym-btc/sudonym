import * as Factory from "factory.ts";
import { RecursivePartial } from "index";
import { User } from "../classes/user";

export const factory = Factory.Sync.makeFactory<RecursivePartial<User>>({
  id: Factory.each(i => i.toString()),
  firebaseId: Factory.each(i => i.toString()),
  lightningAddress: Factory.each(i => i.toString()),
});

export const mocks = factory.buildList(20);