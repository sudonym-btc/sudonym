import { Controller } from '@nestjs/common';
import { BaseController } from 'src/module/base.controller';
import { LnUrl } from './lnurl.model';

import { LnUrlService } from './lnurl.service';

@Controller('lnurl')
export class LnUrlController extends BaseController(LnUrlService, LnUrl) { }