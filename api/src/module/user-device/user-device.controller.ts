import { Controller, Inject } from '@nestjs/common';
import { BaseController } from '../base.controller';
import { UserDevice } from './user-device.model';
import { UserDeviceService } from './user-device.service';

@Controller('userDevice')
export class UserDeviceController extends BaseController({
	service: UserDeviceService,
	model: UserDevice,
	create: {
		update: true,
	},
}) {}
