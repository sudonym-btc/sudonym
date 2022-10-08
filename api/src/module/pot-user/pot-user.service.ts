import { Inject, Injectable } from '@nestjs/common';
import { PotUser } from './pot-user.model';

@Injectable()
export class PotUserService {
	@Inject(PotUser) potUserRepository: typeof PotUser;
}
