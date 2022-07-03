import { Inject, Injectable } from '@nestjs/common';
import { getConfig } from 'src/config/config';

@Injectable()
export class LnUrlService {
    getPayRequest(potId: number) {

        return {
            callback: getConfig().apiUrl + '/receive/lnurlp/' + potId, // The URL from LN SERVICE which will accept the pay request parameters
            maxSendable: 100000000, // Max amount LN SERVICE is willing to receive
            minSendable: 1, // Min amount LN SERVICE is willing to receive, can not be less than 1 or more than `maxSendable`
            metadata: [
                [
                    "text/plain", // mandatory, short description displayed when paying and in transaction log
                    "paying user " // actual metadata content
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
}