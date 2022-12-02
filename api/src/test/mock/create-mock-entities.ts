import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { applyGlobals } from 'app.globals';
import { Config } from 'config/config';
import { ActionService } from 'module/action/action.service';
import { AddressParser } from 'module/action/address-parser/address-parser';
import { AuthService } from 'module/auth/auth.service';
import { Pot } from 'module/pot/pot.model';
import { Receiver } from 'module/receiver/receiver.model';
import { ExchangeService } from 'service/exchange/exchange.service';
import { FIREBASE_ADMIN } from 'service/firebase-admin/firebase-admin';
import { FirebaseNotificationService } from 'service/firebase-notification/firebase-notification.service';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { LightningEvents } from 'service/transaction-listener/lightning-events';
import { AppModule } from '../../app.module';
import { User } from '../../module/user/user.model';
import {
	MockActionService,
	MockAddressParser,
	MockFirebaseAdmin,
	MockFirebaseNotificationService,
	MockLightningEvents,
	MockLightningNodeService,
} from './classes';
import { MockAuthService } from './classes/auth.service.mock';
import { MockExchangeService } from './classes/exchange.service.mock';
import { createPots } from './pot';
import { createUsers } from './user';
const bodyParser = require('body-parser');

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
		.overrideProvider(AuthService)
		.useClass(MockAuthService)
		.overrideProvider(ExchangeService)
		.useClass(MockExchangeService)
		.compile();
	const app = moduleFixture.createNestApplication({
		// logger: console,
	});

	applyGlobals(app);
	await app.init();
	app.get(Config).set({ settle: false, intervalSettle: false });
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
