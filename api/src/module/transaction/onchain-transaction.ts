import { Table, Column, Model } from 'sequelize-typescript'
import * as Models from '@sudonym/models';

@Table
export class OnchainTransaction extends Model implements Models.OnchainTransaction {
  @Column
  txId: string;

  @Column
  fromAddress: string;

  @Column
  toAddress: string;

  @Column
  amount: number;

  @Column
  data: JSON;
}