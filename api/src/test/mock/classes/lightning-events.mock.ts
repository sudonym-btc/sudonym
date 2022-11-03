import { Subject } from 'rxjs';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import {
	LightningEvent,
	LightningEvents,
} from 'service/transaction-listener/lightning-events';

export class MockLightningEvents extends LightningEvents {
	LightningNodeService: LightningNodeService;
	public onEvent: Subject<LightningEvent>;
	reconnect(): void {
		throw new Error('Method not implemented.');
	}
	async onModuleInit() {}
}
