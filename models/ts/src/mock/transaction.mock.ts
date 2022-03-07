import * as Factory from "factory.ts";
import { Transaction } from "../classes/transaction";

export const factory = Factory.Sync.makeFactory<Transaction>({
  id: Factory.each(i => i.toString()),
  transactionId: Factory.each(i => i.toString()),
  potId: Factory.each(i => i.toString()),
  amount: Factory.each(() => parseFloat(((Math.random() - 0.5) * 10000).toFixed(0))),
  OnchainTransactionId: Factory.each(i => i.toString()),
  LightningTransactionId: Factory.each(i => i.toString()),
  createdAt: Factory.Sync.each(() => new Date()),
});
export const mocks = factory.buildList(20);