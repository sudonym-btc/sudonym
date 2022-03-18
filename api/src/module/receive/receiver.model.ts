import { Table, Column, Model, HasMany, CreatedAt, PrimaryKey, Default, DataType } from 'sequelize-typescript'
import * as Models from '@sudonym/models';
import { ADDRESS_TYPES, TAddressType } from '../pay/pay.service';
import {v4 as uuid} from 'uuid';

@Table
export class Receiver extends Model implements Models.Receiver {
  @Default(uuid)
  @PrimaryKey
  @Column
  id: string;

  @Column(DataType.ENUM(...ADDRESS_TYPES))
  type: TAddressType;

  @Column
  potId: string;

  @Column
  data: string;

  @Column
  amount: number;

  @CreatedAt
  @Column
  createdAt: Date;
}