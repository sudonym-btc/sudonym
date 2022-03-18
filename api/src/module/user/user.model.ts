import { Table, Column, Model, HasMany, PrimaryKey, AutoIncrement } from 'sequelize-typescript'
import * as Models from '@sudonym/models';

@Table
export class User extends Model implements Models.User  {
    @PrimaryKey
    @AutoIncrement
    @Column
    id: number

    @Column
    passHash: string

    @Column
    firebaseId: string

    @Column
    lightningAddress: string
}