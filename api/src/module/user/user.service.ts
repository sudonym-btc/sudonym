import { Injectable } from '@nestjs/common';
import { RecursivePartial } from 'sequelize-typescript/dist/shared/types';
import { RequestType } from 'src/helper/parse-request.decorator';
import { BaseService } from '../base.service';
import { User } from './user.model';

@Injectable()
export class UserService extends BaseService(User) {

	async create(params: RecursivePartial<User>, req?: RequestType) {
		try {
			const data = await this.findOne(params.id, req);
			return this.update(data.id, params, req);
		} catch(e) {
			return super.create(params, req);
		}
	}

}