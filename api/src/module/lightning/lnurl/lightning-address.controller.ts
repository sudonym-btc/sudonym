import { Controller, Get, Inject, Param, Query } from "@nestjs/common";
import { Op, Sequelize } from "sequelize";
import { PotUser } from "src/module/pot-user/pot-user.model";
import { Pot } from "src/module/pot/pot.model";
import { User } from "src/module/user/user.model";

import { LnUrlService } from "./lnurl.service";

@Controller('')
export class LightningAddressController {
    @Inject(LnUrlService) lnUrlService: LnUrlService;

    @Get('.well-known/lnurlp/:user')
    async lightningAddress(@Param('user') lightningAddress) {
        const user = await User.findOne({
            where: {
                lightningAddress: lightningAddress.substring(0, lightningAddress.lastIndexOf(".") + 0)

            }
        });

        const pot = await Pot.findOne({
            where: {
                id: {
                    [Op.in]: (await PotUser.findAll({
                        where: {
                            userId: user.id
                        }
                    })).map(i => i.potId)
                }
            },
            order: [Sequelize.literal(`
                name="${lightningAddress.substring(lightningAddress.lastIndexOf("."), lightningAddress.length)}`
            )]
        });

        return (await this.lnUrlService.createPayRequest(pot.id)).params;
    }

}