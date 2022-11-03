import { INestApplication, LogLevel } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { Pot } from 'module/pot/pot.model';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { LightningEvents } from 'service/transaction-listener/lightning-events';
import { AppModule } from '../../app.module';
import { User } from '../../module/user/user.model';
import { createUsers } from './user';
import { createPots } from './pot';
import { Receiver } from 'module/receiver/receiver.model';
import { FIREBASE_ADMIN } from 'service/firebase-admin/firebase-admin';
import { AddressParser } from 'module/action/address-parser/address-parser';
import { ActionService } from 'module/action/action.service';
import { FirebaseNotificationService } from 'service/firebase-notification/firebase-notification.service';
import { applyGlobals } from 'app.globals';
import {
	MockActionService,
	MockAddressParser,
	MockFirebaseAdmin,
	MockFirebaseNotificationService,
	MockLightningEvents,
	MockLightningNodeService,
} from './classes';

export type mockScaffold = {
	app: INestApplication;
	entities: {
		user: User[];
		pot: Pot[];
		onchainReceiver: Receiver;
		lnurlReceiver: Receiver;
		bolt11Receiver: Receiver;
	};
};

export const createMockApp = async () => {
	const moduleFixture = await Test.createTestingModule({
		imports: [AppModule],
	})
		.overrideProvider(FirebaseNotificationService)
		.useClass(MockFirebaseNotificationService)
		.overrideProvider(LightningNodeService)
		.useClass(MockLightningNodeService)
		.overrideProvider(LightningEvents)
		.useClass(MockLightningEvents)
		.overrideProvider(AddressParser)
		.useClass(MockAddressParser)
		.overrideProvider(ActionService)
		.useClass(MockActionService)
		.overrideProvider(FIREBASE_ADMIN)
		.useValue(MockFirebaseAdmin)
		.compile();

	const app = moduleFixture.createNestApplication(null, {
		// logger: console,
	});
	applyGlobals(app);
	await app.init();
	return app;
};

export const createMockEntities = async (app: INestApplication) => {
	const user = await createUsers();
	const pot = await createPots();

	return {
		user,
		pot,
		bolt11Receiver: await Receiver.create({
			potId: pot[0].id,
			type: 'bolt11',
			data: 'lnbc1dfghjk',
		}),
		onchainReceiver: await Receiver.create({
			potId: pot[0].id,
			type: 'onchain',
			data: 'bc1fgwbsknslkmsd',
		}),
		lnurlReceiver: await Receiver.create({
			potId: pot[0].id,
			type: 'onchain',
			data: 'bc1fgwbsknslkmsd',
		}),
	};
};
