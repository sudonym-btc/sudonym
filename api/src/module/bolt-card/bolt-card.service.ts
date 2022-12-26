import { Inject, Injectable } from '@nestjs/common';
import { SenderService } from 'module/sender/sender.service';
import { BaseService } from '../base.service';
import { BoltCard } from './bolt-card.model';

@Injectable()
export class BoltCardService extends BaseService(BoltCard) {
	@Inject() senderService: SenderService;

	async onModuleInit() {
		this.beforeCreate.hook(async (params) => {
			const { entity: sender } = await this.senderService.create({
				...params.Sender,
				type: 'lnurl',
			});
			params.senderId = sender.id;
		});

		super.onModuleInit();
	}
}
