import { Inject, Injectable, Logger } from '@nestjs/common';
import { LightningEvents } from './lightning-events';
import { Event, MSATOSHIS } from '@sudonym/models';
import { TransactionService } from 'module/transaction/transaction.service';
import { EventsService } from 'module/events/events.service';
import { ReceiverService } from 'module/receiver/receiver.service';

@Injectable()
export class EventBroadcaster {
	private readonly logger = new Logger(EventBroadcaster.name);

	@Inject() transactionService: TransactionService;
	@Inject() eventsService: EventsService;
	@Inject() receiverService: ReceiverService;

	listen() {
		this.transactionService.onAfterCreated.subscribe(async (e: any) => {
			if (e.senderId) {
			} else if (e.receiverId) {
				const receiver = await this.receiverService.findOne(
					e.receiverId
				);
				await this.eventsService.trigger(
					new Event('receiver.received', receiver)
				);
				if (receiver.parentId) {
					const parentReceiver = await this.receiverService.findOne(
						e.receiverId
					);
					await this.eventsService.trigger(
						new Event('receiver.received', parentReceiver)
					);
				}
			}
		});
	}
	onModuleInit() {
		this.listen();
	}
}
