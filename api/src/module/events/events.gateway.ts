import { Inject, Logger } from '@nestjs/common';
import {
  OnGatewayConnection,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Event } from '@sudonym/models';
import * as mocks from "@sudonym/models/dist/mock";
import { Socket } from 'dgram';
import { Server } from 'http';
import { EventsService } from './events.service';

@WebSocketGateway(3001, {
  cors: {
    origin: '*',
  },
})
export class EventsGateway implements OnGatewayConnection {

  private readonly logger = new Logger(EventsGateway.name);

  
  @WebSocketServer()
  server: Server;

  @Inject() eventsService: EventsService;

  onModuleInit() {
    this.eventsService.onEvent.listen((e: Event) => {
      this.broadcastToClients([], e);
    })
  }

  broadcastToClients(uids, e: Event) {
    this.server.emit(JSON.stringify(e));
  }

  handleConnection(client: Socket, ...args: any[]) {
    this.logger.verbose('Websocket client connected');
    setInterval(() => {
      // client.send(JSON.stringify(new Event('transaction.created', mocks.transaction.mocks[0])));
    }, 5000);
  }

}