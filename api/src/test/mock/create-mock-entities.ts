import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { Subject } from 'rxjs';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { LightningEvents } from 'service/transaction-listener/lightning-events';
import { AppModule } from '../../app.module';
import { User } from '../../module/user/user.model';
import { createUsers } from './user';

export type mockScaffold = {
	app: INestApplication;
	entities: {
		user: User[];
	};
};

export const createMockApp = async () => {
	const moduleFixture = await Test.createTestingModule({
		imports: [AppModule]
	})
		.overrideProvider(LightningNodeService)
		.useClass(MockLightningNodeService)
		.overrideProvider(LightningEvents)
		.useClass(MockLightningEvents)
		.compile();

	const app = moduleFixture.createNestApplication();
	await app.init();
	return app;
};

export const createMockEntities = async () => {
	return {
		user: await createUsers(),
	};
};

class MockLightningEvents extends LightningEvents {
	LightningNodeService: LightningNodeService;
	public onEvent: Subject<unknown>;
	reconnect(): void {
		throw new Error('Method not implemented.');
	}
	async onModuleInit() {
	}

}

class MockLightningNodeService extends LightningNodeService {
	findCircular(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	async onModuleInit(): Promise<void> {
	}
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
	pay(invoice: any): Promise<any> {
		throw new Error('Method not implemented.');
	}
	createOffer(amount: any, description?: any): Promise<any> {
		throw new Error('Method not implemented.');
	}
	fetchOfferInvoice(offer: any): Promise<any> {
		throw new Error('Method not implemented.');
	}
	generateOnChainAddress(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	withdrawOnChain(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	rpc(method: any, params: any): Promise<any> {
		throw new Error('Method not implemented.');
	}
	decodeInvoice(invoice: any): Promise<any> {
		throw new Error('Method not implemented.');
	}
	makeRequest(options: any): Promise<any> {
		throw new Error('Method not implemented.');
	}

}