import { Table, Column, Model, HasMany, PrimaryKey, AutoIncrement } from 'sequelize-typescript'
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';

@Table
export class UserDevice extends BaseModel implements Models.UserDevice  {
    @PrimaryKey
    @Column
    id: string

    @Column
    uid: string

    @Column
    token: string
}