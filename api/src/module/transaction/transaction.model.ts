import { Table, Column, Model, HasMany, CreatedAt, PrimaryKey } from 'sequelize-typescript'
import * as Models from '@sudonym/models';

@Table
export class Transaction extends Model implements Models.Transaction {
  @Column
  addressType: string;
  @Column
  address: string;
  @Column
  confirmed: boolean;
  @PrimaryKey
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

  @Column
  outgoing: boolean;

  @CreatedAt
  @Column
  createdAt: Date;
}