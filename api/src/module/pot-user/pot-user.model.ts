import { Table, Column, Model, HasMany, PrimaryKey, AutoIncrement } from 'sequelize-typescript'
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';

@Table({
    scopes: PotUser.scopes
})
export class PotUser extends BaseModel implements Models.PotUser {
    @PrimaryKey
    @AutoIncrement
    @Column
    id: number

    @Column
    potId: number

    @Column
    userId: number
}