import { Table, Column, Model, HasMany, CreatedAt } from 'sequelize-typescript'
import * as Models from '@sudonym/models';

@Table
export class Transaction extends Model implements Models.Transaction {
  @Column
  id: string;

  @Column
  transactionId: string;

  @Column
  potId: string;

  @Column
  spendable: boolean;

  @Column
  amount: number;

  @Column
  LightningInvoiceId: string;

  @Column
  OnchainTransactionId: string;

  @CreatedAt
  @Column
  createdAt: Date;
}