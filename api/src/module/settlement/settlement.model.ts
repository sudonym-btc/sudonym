import { Table, Column, Model, HasMany, PrimaryKey, AutoIncrement } from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';

@Table
export class Settlement extends BaseModel implements Models.Settlement  {
    @PrimaryKey
    @Column
    id: number

    @Column
    fromCurrency: string

    @Column
    toCurrency: string

    @Column
    amount: number

    @Column
    exchangeId: string

    @Column
    status: boolean

    @Column
    orderId: string
}