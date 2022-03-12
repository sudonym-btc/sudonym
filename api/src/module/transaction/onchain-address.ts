import { Table, Column, Model } from 'sequelize-typescript'
import * as Models from '@sudonym/models';

@Table
export class OnchainAddress extends Model implements Models.OnchainAddress {
  @Column
  id: string;

  @Column
  potId: string;

  @Column
  address: string;
}