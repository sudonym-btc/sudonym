import { Logger } from '@nestjs/common';
import { Sequelize } from 'sequelize-typescript';
import { Config } from '../config/config';
import { LnUrl } from '../module/lightning/lnurl/lnurl.model';
import { PotUser } from '../module/pot-user/pot-user.model';
import { Pot } from '../module/pot/pot.model';
import { Receiver } from '../module/receiver/receiver.model';
import { SettlementTransaction } from '../module/settlement-transaction/settlement-transaction.model';
import { Settlement } from '../module/settlement/settlement.model';
import { Transaction } from '../module/transaction/transaction.model';
import { UserDevice } from '../module/user-device/user-device.model';
import { User } from '../module/user/user.model';

import * as cls from 'cls-hooked';
import { BillSplitParticipant } from 'module/bill-split-participant/bill-split-participant.model';
import { BillSplit } from 'module/bill-split/bill-split.model';
import { BoltCard } from 'module/bolt-card/bolt-card.model';
import { ContactAddress } from 'module/contact-address/contact-address.model';
import { Contact } from 'module/contact/contact.model';
import { Sender } from 'module/sender/sender.model';
import { TransactionTag } from 'module/transaction-tag/transaction-tag.model';

export const sequelizeCls = cls.createNamespace('sequelize');
Sequelize.useCLS(sequelizeCls);

export const databaseProviders = [
	{
		provide: 'SEQUELIZE',
		inject: [Config],
		useFactory: async (config: Config) => {
			const logger = new Logger('DB');
			logger.log('Initializing db:', {
				...config.database,
			});

			const dbInit = new Sequelize({
				...config.database,
				database: null,
				logging: (e) => {
					logger.verbose(e);
				},
			});
			await dbInit.query(
				`CREATE DATABASE IF NOT EXISTS \`${config.database.database}\`;`
			);
			dbInit.close();

			const sequelize = new Sequelize({
				...config.database,
				logging: (e) => {
					// console.log(e);
					// logger.verbose(e);
				},
				models: [
					BillSplit,
					BillSplitParticipant,
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
					TransactionTag,
					Settlement,
					SettlementTransaction,
				],
			});
			await sequelize.sync({
				alter: false,
				force: config.env == 'production' ? false : false,
			});
			return sequelize;
		},
	},
];
