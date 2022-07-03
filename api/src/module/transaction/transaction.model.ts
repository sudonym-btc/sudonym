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
  txid: string;

  @Column
  type: string;

  @Column
  description: string;

  @Column
  address: string;

  @Default(null)
  @Column
  status: boolean;

  @Column
  transactionId: number;

  @Column
  potId: number;

  @AllowNull(false)
  @Column
  amount: number;

  @AllowNull(false)
  @Column
  outgoing: boolean;

  @AllowNull(false)
  @Default('BTC')
  @Column
  currencyCode: string;

  @CreatedAt
  @Column
  createdAt: Date;
}