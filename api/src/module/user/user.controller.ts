import { Controller, Inject } from '@nestjs/common';
import { User } from '@sudonym/models';
import { BaseController } from '../base.controller';
import { UserService } from './user.service';

@Controller('user')
export class UserController extends BaseController(
  UserService,
  User
) {

  async onModuleInit() {
    // console.log((await this.service.findOne(1)).firebaseId);
  }
}