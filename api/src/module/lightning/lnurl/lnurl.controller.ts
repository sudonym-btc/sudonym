import { Controller, Get, Param, Query } from '@nestjs/common';
import { RequestType } from 'helper/parse-request.decorator';
import { BaseController } from 'module/base.controller';
import { LnUrl } from './lnurl.model';

import { LnUrlService } from './lnurl.service';

@Controller('lnurl')
export class LnUrlController extends BaseController(LnUrlService, LnUrl) {
    @Get(':id')
    async overwriteFindOne(@Param('id') id, req?: RequestType) {
        return (await this.service.findOne(id)).params;
    }
}
