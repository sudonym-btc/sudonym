import { Inject, Injectable } from '@nestjs/common';
import { RecursivePartial } from 'sequelize-typescript/dist/shared/types';
import { RequestType } from 'helper/parse-request.decorator';
import { BaseService } from '../base.service';
import { User } from './user.model';
import { PotService } from 'module/pot/pot.service';
import { generateUsername } from 'unique-username-generator';
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
	async create(params: RecursivePartial<User>, req?: RequestType) {
		try {
			const data = await this.findOne(params.id, req);
			return this.update(data.id, params, req);
		} catch (e) {
			params.lightningAddress ??= generateUsername('', 0);
			return super.create(params, req);
		}
	}
}
