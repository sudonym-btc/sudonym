import { Module } from '@nestjs/common';
import { SharedModule } from '../shared.module';
import { UserDeviceController } from './user-device.controller';
import { UserDevice } from './user-device.model';
import { UserDeviceService } from './user-device.service';

@Module({
	imports: [SharedModule],
	controllers: [UserDeviceController],
	providers: [
		UserDeviceService,
		{
			provide: UserDevice,
			useValue: UserDevice,
		},
	],
	exports: [UserDeviceService],
})
export class UserDeviceModule {}
