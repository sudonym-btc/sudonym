import * as Factory from "factory.ts";
import { User } from "../classes/user";

export const factory = Factory.Sync.makeFactory<User>({
  id: Factory.each(i => i),
  passHash: Factory.each(i => i.toString()),
  firebaseId: Factory.each(i => i.toString()),
  lightningAddress: Factory.each(i => i.toString()),
});

export const mocks = factory.buildList(20);