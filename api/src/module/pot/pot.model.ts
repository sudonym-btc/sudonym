import { Table, Column, Model, HasMany, PrimaryKey, AutoIncrement } from 'sequelize-typescript'
import * as Models from '@sudonym/models';
import { CurrencyCode } from '@sudonym/models';

@Table
export class Pot extends Model implements Models.Pot {
    @PrimaryKey
    @AutoIncrement
    @Column
    id: string

    @Column
    name: string

    @Column
    balance: number

    @Column
    currency: CurrencyCode;
}