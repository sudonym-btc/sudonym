import { Table, Column, Model, HasMany, CreatedAt } from 'sequelize-typescript'
import * as Models from '@sudonym/models';
import { TAddressType } from '../pay/pay.service';

@Table
export class Receiver extends Model implements Models.Receiver {
  @Column
  id: string;

  @Column
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