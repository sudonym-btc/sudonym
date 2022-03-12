import { Table, Column, Model, HasMany, PrimaryKey, AutoIncrement } from 'sequelize-typescript'
import * as Models from '@sudonym/models';

@Table
export class PotUser extends Model implements Models.PotUser {
    @PrimaryKey
    @AutoIncrement
    @Column
    id: number

    @Column
    potId: number

    @Column
    userId: number
}