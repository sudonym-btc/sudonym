import { Module } from '@nestjs/common';
import { PotModule } from 'module/pot/pot.module';
import { SharedModule } from '../shared.module';
import { UserController } from './user.controller';
import { User } from './user.model';
import { UserService } from './user.service';

@Module({
	imports: [SharedModule, PotModule],
	controllers: [UserController],
	providers: [
		UserService,
		{
			provide: User,
			useValue: User,
		},
	],
	exports: [UserService],
})
export class UserModule {}
