import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { Pot } from 'module/pot/pot.model';
import { Subject } from 'rxjs';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import {
	LightningEvent,
	LightningEvents,
} from 'service/transaction-listener/lightning-events';
import { AppModule } from '../../app.module';
import { User } from '../../module/user/user.model';
import { createUsers } from './user';
import { createPots } from './pot';
import { Receiver } from 'module/receiver/receiver.model';
import { FIREBASE_ADMIN } from 'service/firebase-admin/firebase-admin';
import { AddressParser } from 'module/action/address-parser/address-parser';
import { WithdrawRequest } from '@sudonym/models';

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
		.overrideProvider(LightningNodeService)
		.useClass(MockLightningNodeService)
		.overrideProvider(LightningEvents)
		.useClass(MockLightningEvents)
		.overrideProvider(AddressParser)
		.useClass(MockAddressParser)
		.overrideProvider(FIREBASE_ADMIN)
		.useValue(MockFirebaseAdmin)
		.compile();

	const app = moduleFixture.createNestApplication();
	await app.init();
	return app;
};

export const createMockEntities = async () => {
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

class MockLightningEvents extends LightningEvents {
	LightningNodeService: LightningNodeService;
	public onEvent: Subject<LightningEvent>;
	reconnect(): void {
		throw new Error('Method not implemented.');
	}
	async onModuleInit() {}
}

class MockLightningNodeService extends LightningNodeService {
	findCircular(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	async onModuleInit(): Promise<void> {}
	getInfo(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	listPeers(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	listChannels(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	getInvoices(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	createInvoice(amount: any, label?: any, description?: any): Promise<any> {
		throw new Error('Method not implemented.');
	}
	getFees(pubkey: any, amount?: number): Promise<number> {
		throw new Error('Method not implemented.');
	}
	getRoute(pubkey: any, amount?: number): Promise<any> {
		throw new Error('Method not implemented.');
	}

	pay = jest.fn(async (invoice) => {
		console.log('PAYYYY');
	}) as any;

	createOffer(amount: any, description?: any): Promise<any> {
		throw new Error('Method not implemented.');
	}
	fetchOfferInvoice(offer: any): Promise<any> {
		throw new Error('Method not implemented.');
	}
	generateOnChainAddress(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	withdrawOnChain = jest.fn(async (invoice) => {
		console.log('withdraw');
	}) as any;
	rpc = jest.fn(
		async (method: any, params: any) => 'Method not implemente'
	) as any;

	decodeInvoice(invoice: any): Promise<any> {
		throw new Error('Method not implemented.');
	}
	makeRequest(options: any): Promise<any> {
		throw new Error('Method not implemented.');
	}
}

class MockAddressParser extends AddressParser {
	fetchRemoteLnUrl = async (invoice: string) => {
		const parsedUrl = this.parseLnUrlString(invoice);
		if (parsedUrl.includes('lnurlw')) {
			return {
				success: true,
				data: {
					tag: 'withdrawRequest', // type of LNURL
					callback: parsedUrl, // The URL which LN SERVICE would accept a withdrawal Lightning invoice as query parameter
					k1: null, // Random or non-random string to identify the user's LN WALLET when using the callback URL
					defaultDescription: 'hi', // A default withdrawal invoice description
					minWithdrawable: 1000, // Min amount (in millisatoshis) the user can withdraw from LN SERVICE, or 0
					maxWithdrawable: 1000, // Max amount (in millisatoshis) the user can withdraw from LN SERVICE, or equal to minWithdrawable if the user has no choice over the amounts
				} as WithdrawRequest,
			};
		} else {
		}
	};
}

const MockFirebaseAdmin = {
	auth: () => ({}),
	messaging: () => ({
		send: async (info) => info,
	}),
};
