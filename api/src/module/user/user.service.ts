import { Injectable } from '@nestjs/common';
import { RecursivePartial } from 'sequelize-typescript/dist/shared/types';
import { RequestType } from 'helper/parse-request.decorator';
import { BaseService } from '../base.service';
import { User } from './user.model';

@Injectable()
export class UserService extends BaseService(User) {
	async create(params: RecursivePartial<User>, req?: RequestType) {
		console.log(params);
		try {
			const data = await this.findOne(params.id, req);
			console.log(data);
			return this.update(data.id, params, req);
		} catch (e) {
			console.log("creting");
			return super.create(params, req);
		}
	}
}
