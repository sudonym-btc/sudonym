import { Controller, Get, Inject, Param, Query } from "@nestjs/common";
import { ReceiveService } from "src/module/receive/receive.service";
import { LnUrlService } from "../lnurl.service";
import fetch from 'node-fetch';
import { selfSignedHttpsAgent } from "src/module/pay/address-parser";
import { getConfig } from "src/config/config";
import { MSATOSHIS } from "@sudonym/models";


export class LnUrlHandlerService {
    @Inject(LnUrlService) lnUrlService: LnUrlService;
    @Inject(ReceiveService) receiveService: ReceiveService;

    async handle(id, amount) {
        const tag = await this.lnUrlService.findOne(id);
        const receiver = await this.receiveService.getInvoice(tag.potId, 'bolt11', amount / MSATOSHIS);
        return {
            pr: receiver.data,
            routes: []
        }
    }

    async getCallback(callback, params) {
        return fetch(callback + "?" + new URLSearchParams(params), getConfig().env == "development" ? {
            agent: selfSignedHttpsAgent
        } : {})
        .then(r => r.json())
    }

}