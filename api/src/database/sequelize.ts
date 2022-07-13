import { Sequelize } from 'sequelize-typescript'
import { PotUser } from '../module/pot-user/pot-user.model';
import { Pot } from '../module/pot/pot.model';
import { Receiver } from '../module/receive/receiver.model';
import { getConfig } from '../config/config';
import { User } from '../module/user/user.model';
import { Transaction } from '../module/transaction/transaction.model';
import { Logger } from '@nestjs/common';
import { TransactionSettlement } from '../module/transaction-settlement/transaction-settlement.model';
import { LnUrl } from '../module/lightning/lnurl/lnurl.model';

const logger = new Logger('DB');
logger.log('Initializing db:', getConfig().database)

export const sequelize = new Sequelize({
  ...getConfig().database,
  logging: (e) => logger.verbose(e),
  models: [
      Pot,
      PotUser,
      Receiver,
      User,
      LnUrl,
      Transaction,
      TransactionSettlement
  ]
});