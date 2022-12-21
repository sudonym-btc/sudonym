import { Inject, Injectable } from '@nestjs/common';
import { authUserIdGetter } from 'helper/context-request';
import { PotService } from 'module/pot/pot.service';
import { RecursivePartial } from 'sequelize-typescript/dist/shared/types';
import { generateUsername } from 'unique-username-generator';
import { BaseService } from '../base.service';
import { User } from './user.model';
@Injectable()
export class UserService extends BaseService(User) {
	@Inject(PotService) potService: PotService;

	async onModuleInit(): Promise<any> {
		this.afterCreate.hook(async () => {
			await this.potService.create({
				currency: 'BTC',
				name: 'Default',
			});
		});
	}
	async create(params: RecursivePartial<User>) {
		params.firebaseId = params.id = authUserIdGetter();
		try {
			const data = await this.findOne(params.id);
			return this.update(data.id, params);
		} catch (e) {
			params.lightningAddress ??= generateUsername('-', 0);
			return super.create(params);
		}
	}
}
