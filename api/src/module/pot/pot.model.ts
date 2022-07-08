import { Table, Column, Model, HasMany, PrimaryKey, AutoIncrement, Sequelize } from 'sequelize-typescript'
import * as Models from '@sudonym/models';
import { CurrencyCode } from '@sudonym/models';
import { PotUser } from '../pot-user/pot-user.model';
import { RequestType } from 'src/helper/parse-request.decorator';
import { BaseModel } from '../base.model';

@Table({
    scopes: Pot.scopes
})
export class Pot extends BaseModel implements Models.Pot {
    @PrimaryKey
    @AutoIncrement
    @Column
    id: number

    @Column
    name: string

    @Column
    balance: number

    @Column
    spendableBalance: number

    @Column
    currency: CurrencyCode;

    static scopes = {
        access: (request: RequestType) => ({
            include: [{
                model: PotUser,
                required: true,
                where: {
                    UserId: request.auth.uid
                }
            }]
        })
    }
}