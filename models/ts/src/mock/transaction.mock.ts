import * as Factory from "factory.ts";
import { Transaction } from "../classes/transaction";

export const factory = Factory.Sync.makeFactory<Transaction>({
  id: Factory.each(i => i.toString()),
  outgoing: Factory.each(i => Boolean(Math.random() > 0.5)),
  address: 'lnurl23423432',
  addressType: 'lnurl',
  confirmed: true,
  transactionId: Factory.each(i => i.toString()),
  potId: Factory.each(i => i.toString()),
  amount: Factory.each(() => parseFloat(((Math.random() - 0.5) * 10000).toFixed(0))),
  spendable: Factory.each(() => Boolean(Math.round(Math.random()))),
  OnchainTransactionId: Factory.each(i => i.toString()),
  LightningInvoiceId: Factory.each(i => i.toString()),
  createdAt: Factory.Sync.each(() => new Date()),
});
export const mocks = factory.buildList(20);