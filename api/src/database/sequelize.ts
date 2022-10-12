import { Sequelize } from 'sequelize-typescript';
import { PotUser } from '../module/pot-user/pot-user.model';
import { Pot } from '../module/pot/pot.model';
import { Receiver } from '../module/receiver/receiver.model';
import { getConfig } from '../config/config';
import { User } from '../module/user/user.model';
import { Transaction } from '../module/transaction/transaction.model';
import { Logger } from '@nestjs/common';
import { LnUrl } from '../module/lightning/lnurl/lnurl.model';
import { UserDevice } from '../module/user-device/user-device.model';
import { Settlement } from '../module/settlement/settlement.model';
import { SettlementTransaction } from '../module/settlement-transaction/settlement-transaction.model';

import * as cls from 'cls-hooked';
import { ContactAddress } from 'module/contact-address/contact-address.model';
import { Contact } from 'module/contact/contact.model';
import { BoltCard } from 'module/bolt-card/bolt-card.model';
import { Sender } from 'module/sender/sender.model';

const logger = new Logger('DB');
logger.log('Initializing db:', getConfig().database);

export const sequelizeCls = cls.createNamespace('sequelize');
Sequelize.useCLS(sequelizeCls);

export const sequelize = new Sequelize({
	...getConfig().database,
	logging: (e) => {
		// logger.verbose(e)
	},
	models: [
		Pot,
		PotUser,
		BoltCard,
		Contact,
		ContactAddress,
		Receiver,
		Sender,
		User,
		UserDevice,
		LnUrl,
		Transaction,
		Settlement,
		SettlementTransaction,
	],
});
