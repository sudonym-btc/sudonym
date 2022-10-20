import { Controller } from '@nestjs/common';
import { BaseController } from 'module/base.controller';
import { Sender } from './sender.model';
import { SenderService } from './sender.service';

@Controller('sender')
export class SenderController extends BaseController(SenderService, Sender) {}
