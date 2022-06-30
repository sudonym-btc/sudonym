import { Inject, Injectable } from "@nestjs/common";
import { LightningEvents } from "./lightning-events";
import { TransactionService } from "src/module/transaction/transaction.service";
import { TransactionListener } from "./transaction-listener.interface";
import { LightningNodeService } from "../lightning-node/lightning-node.service";

@Injectable()
export class LightningListener extends TransactionListener {

    @Inject() lightningNodeService: LightningNodeService;
    @Inject() lightningEvents: LightningEvents;

    listenIncoming() {
        this.lightningEvents.onEvent.subscribe(async (e: any) => {
            if(e.event == 'invoice') {
                const receivers = await this.receiveService.find({
                    where: {
                        data: e.data.bolt11
                    }
                });

                if(receivers.length) {
                    await this.transactionService.create({
                        potId: receivers[0].potId,
                        outgoing: false,
                        amount: e.event.msatoshi/1000,
                        confirmed: true,
                        spendable: true,
                        LightningInvoiceId: e.event.bolt11
                    })
                }
            }
        });
    }

    listenOutgoing() {
        this.transactionService.onAfterCreated.listen(async (transaction) => {
            console.log(transaction);
            if (transaction.outgoing && ['lnurl', 'bolt11', 'bolt12'].includes(transaction.addressType)) {
                let bolt11;
                switch(transaction.addressType) {
                    case 'bolt11':
                        bolt11 = transaction.address;
                        break;
                    case 'bolt12':
                        bolt11 = await this.lightningNodeService.fetchOfferInvoice(transaction.address);
                        break;
                    case 'lnurl':
                        // bolt11 = await this.lightningNodeService.fetchOfferInvoice(transaction.address);
                        break;
                }
                await this.transactionService.update(transaction.id, {
                    LightningInvoiceId: bolt11
                })
                this.lightningNodeService.pay(bolt11);
            }
        });

        this.lightningEvents.onEvent.subscribe(e => {
            
        })
    }

}
