import { Table, Column, Model, HasMany, PrimaryKey, AutoIncrement } from 'sequelize-typescript'
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';

@Table
export class User extends BaseModel implements Models.User  {
    @PrimaryKey
    @Column
    id: string

    @Column
    firebaseId: string

    @Column
    lightningAddress: string
}