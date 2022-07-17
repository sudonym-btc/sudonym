import { Injectable } from '@nestjs/common';
import { BaseService } from '../base.service';
import { UserDevice } from './user-device.model';

@Injectable()
export class UserDeviceService extends BaseService(UserDevice) {
}