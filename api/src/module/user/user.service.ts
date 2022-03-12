import { Inject, Injectable } from '@nestjs/common';
import { BaseService } from '../base.service';
import { PotService } from '../pot/pot.service';
import { User } from './user.model';

@Injectable()
export class UserService extends BaseService(User) {

    createInvoice() {

    }

    xyz() {
        
    }
}