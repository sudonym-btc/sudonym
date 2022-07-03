import { Table, Column, Model, CreatedAt, PrimaryKey, DataType, AutoIncrement } from 'sequelize-typescript'
import * as Models from '@sudonym/models';
import { ADDRESS_TYPES, TAddressType } from '../pay/pay.service';
import { CurrencyCode } from '@sudonym/models';

@Table
export class Receiver extends Model implements Models.Receiver {
  @PrimaryKey
  @AutoIncrement
  @Column
  id: number;

  @Column(DataType.ENUM(...ADDRESS_TYPES))
  type: TAddressType;

  @Column
  potId: number;

  @Column
  data: string;

  @Column
  amount: number;

  @Column
  amountCurrency: CurrencyCode;

  @CreatedAt
  @Column
  createdAt: Date;
}