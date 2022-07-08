import { Table, Column, Model, HasMany, CreatedAt, PrimaryKey, Default, AutoIncrement, AllowNull, NotNull } from 'sequelize-typescript'
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';

@Table({
  scopes: TransactionSettlement.scopes
})
export class TransactionSettlement extends BaseModel implements Models.TransactionSettlement {

  @AutoIncrement
  @PrimaryKey
  @AllowNull(false)
  @Default(() => Math.floor(Math.random() * 100000000))
  @Column
  id: number;

  @Column
  transactionId: number;

  @AllowNull(true)
  @Column
  status: boolean;

  @CreatedAt
  @Column
  createdAt: Date;
}