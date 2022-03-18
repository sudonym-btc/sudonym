import { Sequelize } from 'sequelize-typescript'
import { PotUser } from '../module/pot-user/pot-user.model';
import { Pot } from '../module/pot/pot.model';
import { Receiver } from '../module/receive/receiver.model';
import { getConfig } from '../config/config';
import { User } from '../module/user/user.model';
import { Transaction } from '../module/transaction/transaction.model';

console.debug('initializing db:', getConfig().database)
export const sequelize = new Sequelize({
  ...getConfig().database,
  models: [
      Pot,
      PotUser,
      Receiver,
      User,
      Transaction
  ]
});