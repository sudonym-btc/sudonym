import { Table, Column, Model, HasMany, CreatedAt, PrimaryKey, Default, AutoIncrement, AllowNull, NotNull } from 'sequelize-typescript'
import * as Models from '@sudonym/models';

@Table
export class Transaction extends Model implements Models.Transaction {

  @AutoIncrement
  @PrimaryKey
  @AllowNull(false)
  @Default(() => Math.floor(Math.random() * 100000000))
  @Column
  id: number;

  @Column
  addressType: string;

  @Column
  address: string;

  @Default(false)
  @Column
  confirmed: boolean;

  @Column
  transactionId: string;

  @Column
  potId: string;

  @Default(false)
  @Column
  spendable: boolean;

  @AllowNull(false)
  @Column
  amount: number;

  @Column
  LightningInvoiceId: string;

  @Column
  OnchainTransactionId: string;

  @AllowNull(false)
  @Column
  outgoing: boolean;

  @CreatedAt
  @Column
  createdAt: Date;
}