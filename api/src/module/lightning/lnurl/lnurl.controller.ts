import { Controller, Get, Inject, Param, Query } from "@nestjs/common";
import { Op } from "sequelize";
import { PotUser } from "src/module/pot-user/pot-user.model";
import { Pot } from "src/module/pot/pot.model";
import { User } from "src/module/user/user.model";

import { ReceiveService } from "../../receive/receive.service";
import { LnUrlService } from "./lnurl.service";

@Controller('')
export class LnUrlController {
    @Inject(LnUrlService) lnUrlService: LnUrlService;

    @Get('.well-known/lnurlp/:user')
    async pay(@Param('user') lightningAddress) {
        const user = await User.findOne({
            where: {
                lightningAddress
            }
        });

        const pot = await Pot.findOne({
            where: {
                id: {
                    [Op.in]: (await PotUser.findAll({
                        where: {
                            UserId: user.id
                        }
                    })).map(i => i.potId)
                }
            }
        });

        return this.lnUrlService.getPayRequest(pot.id);
    }

}