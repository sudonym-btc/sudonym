import { Sequelize } from 'sequelize-typescript';
import { PotUser } from '../module/pot-user/pot-user.model';
import { Pot } from '../module/pot/pot.model';
import { Receiver } from '../module/receive/receiver.model';
import { getConfig } from '../config/config';
import { User } from '../module/user/user.model';
import { Transaction } from '../module/transaction/transaction.model';
import { Logger } from '@nestjs/common';
import { LnUrl } from '../module/lightning/lnurl/lnurl.model';
import { UserDevice } from '../module/user-device/user-device.model';
import { Settlement } from '../module/settlement/settlement.model';
import { SettlementTransaction } from '../module/settlement-transaction/settlement-transaction.model';

import * as cls from 'cls-hooked';

const logger = new Logger('DB');
logger.log('Initializing db:', getConfig().database);

export const sequelizeCls = cls.createNamespace('sequelize');
Sequelize.useCLS(sequelizeCls);

export const sequelize = new Sequelize({
	...getConfig().database,
	logging: (e) => logger.verbose(e),
	models: [
		Pot,
		PotUser,
		Receiver,
		User,
		UserDevice,
		LnUrl,
		Transaction,
		Settlement,
		SettlementTransaction
	]
});