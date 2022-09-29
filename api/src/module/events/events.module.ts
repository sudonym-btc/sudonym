import { Module } from '@nestjs/common';
import { AuthModule } from 'module/auth/auth.module';
import { EventsGateway } from './events.gateway';
import { EventsService } from './events.service';

@Module({
	imports: [AuthModule],
	providers: [EventsService, EventsGateway],
	exports: [EventsService],
})
export class EventsModule {}
