import * as Factory from "factory.ts";
import { Transaction } from "../classes/transaction";

export const factory = Factory.Sync.makeFactory<Transaction>({
  id: Factory.each(i => i.toString()),
  transactionId: Factory.each(i => i.toString()),
  potId: Factory.each(i => i.toString()),
  amount: (Math.random() - 1) * 0.00001,
  OnchainTransactionId: Factory.each(i => i.toString()),
  LightningTransactionId: Factory.each(i => i.toString()),
});
export const mocks = factory.buildList(20);