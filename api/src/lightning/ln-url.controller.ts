import { Controller, Get, Inject, Param, Query } from "@nestjs/common";
import { getConfig } from "src/config/config";
import { LightningService } from "./lightning.service";

@Controller('')
export class LnUrlController {
    @Inject(LightningService) lightningService: LightningService;

    @Get('.well-known/lnurlp/:user')
    pay(@Param('user') user) {
        return {
            callback: getConfig().apiUrl + '', // The URL from LN SERVICE which will accept the pay request parameters
            maxSendable: 100000000, // Max amount LN SERVICE is willing to receive
            minSendable: 1000, // Min amount LN SERVICE is willing to receive, can not be less than 1 or more than `maxSendable`
            metadata: [
                [
                    "text/plain", // mandatory, short description displayed when paying and in transaction log
                    "paying user " + user // actual metadata content
                ],
                [
                    "text/long-desc", // optional longer description of the payment, MAY contain newlines
                    "" // actual metadata content
                ],
                // [
                //     "image/png;base64", // optional 512x512px PNG thumbnail which will represent this lnurl in a list or grid
                //     content // base64 string, up to 136536 characters (100Kb of image data in base-64 encoding)
                // ],
                // [
                //     "image/jpeg;base64", // optional 512x512px JPG thumbnail which will represent this lnurl in a list or grid
                //     content // base64 string, up to 136536 characters (100Kb of image data in base-64 encoding)
                // ],
                // ... // more objects for future types
            ], // Metadata json which must be presented as raw string here, this is required to pass signature verification at a later step
            tag: "payRequest" // Type of LNURL
        }
    }
    @Get('/lnurlp/:id')
    getInvoice(@Query('amount') amount: number, @Param('id') id) {
        return {
            pr: this.lightningService.createInvoice(), // bech32-serialized lightning invoice
            routes: [], // an empty array
        }
    }
}