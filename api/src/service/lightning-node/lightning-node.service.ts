import * as https from 'https';
import * as fs from 'fs';
import axios from 'axios';
import { getConfig } from '../../config/config';
import { Injectable } from '@nestjs/common';
import { v4 as uuid } from 'uuid';
import * as bolt11 from 'bolt11';

@Injectable()
export class LightningNodeService {

    private macaroon = Buffer.from(fs.readFileSync(getConfig().macaroonFile)).toString("base64");
    private url = getConfig().lightningREST;
    private info;
    private peers;
    private connectedChannels;

    async findCircular() {
        const validEntryAndExists = [];
        for (const outgoing of this.connectedChannels) {
            for (const incoming of this.connectedChannels) {
                if (outgoing == incoming) continue;
                validEntryAndExists.push({ outgoing, incoming });
            }
        }

        const validEntryExitIds = validEntryAndExists
            .map(e => [e.outgoing.id, e.incoming.id]);

        // console.log(validEntryAndExists);

        const channels = (await this.rpc('listchannels', [])).channels;
        // console.log(channels.map(c => [c.source, c.destination]));
        // console.log('validEntryAndExitRemoteNodeIds', validEntryExitIds);

        const circles = [];
        const relevantChannels = channels.filter(c => {
            const vv = validEntryExitIds.find(v => {
                return (v[0] == c.source && v[1] == c.destination)
                    || (v[0] == c.destination && v[1] == c.source);

            });
            if (!!vv) {
                const circle = [this.connectedChannels.find(c => c.id == vv[0]), c, this.connectedChannels.find(c => c.id == vv[1])];
                circles.push(circle);
            }
            return !!vv;
        });

        // @todo: order by capacity

        // console.log(circles);
        return circles[0];


    }

    async onModuleInit() {

        this.info = await this.getInfo();
        this.connectedChannels = await this.listChannels();
        this.peers = await this.listPeers();

        // console.log(await this.rpc('sendpay', [[{
        //     "id": "02cf9cc78da5244021f549bfdac1494cb3ec9ee42fc351febe69a65b345158456e",
        //     "channel": "421x1x1",
        //     "direction": 1,
        //     "msatoshi": 2,
        //     "amount_msat": "2msat",
        //     "delay": 21,
        //     "style": "tlv"
        //  },
        //  {
        //     "id": "024c3c52eca55ef722b5342efb9f899ab29f9b6f43f036d3669b14bba9499c6d82",
        //     "channel": "631x1x0",
        //     "direction": 1,
        //     "msatoshi": 1,
        //     "amount_msat": "1msat",
        //     "delay": 15,
        //     "style": "tlv"
        //  },
        //  {
        //     "id": "039afc2a89d74ecc34465cb0476b4c87ec6a5ca646ddcb7f30ee7daab118ce06be",
        //     "channel": "526x1x1",
        //     "direction": 0,
        //     "msatoshi": 1,
        //     "amount_msat": "1msat",
        //     "delay": 9,
        //     "style": "tlv"
        //  }
        // ], "f2c1bbaac7eb6d9bc3a848909ae1098ed0de2eb8f7685fd5fa673578e8271ffd", "test", 1, "lnbcrt10p1p3tezzpsp5aqgjr7j43xka5ftyaftmy4ytk24w4swl30wlt8ndwzzpgdw6e06qpp57tqmh2k8adkehsagfzgf4cgf3mgdut4c7a59l406vu6h36p8rl7sdq0wdjkcenjda6hgegxqyjw5qcqp2rzjqt8ee3ud55jyqg04fxla4s2ffje7e8hy9lp4rl47dxn9kdz3tpzkuqqp55qqqqgqqyqqqqqpqqqqqzsqqc9qyysgqfq5cyyw56rf57n3u8duc75teggrzql3dk4003tkglvvgnt2d6w88v2qscg8l4nney8rjx6l7ufkq6f9d460glw6e5mn98cddl8ahfycpg2um5z", "e81121fa5589adda2564ea57b2548bb2aaeac1df8bddf59e6d70841435dacbf4"]));
        // console.log(await this.rpc('getinfo', []));

    }

    async getInfo() {
        return this.makeRequest({
            path: '/v1/getinfo'
        });
    }
    async listPeers() {
        return this.makeRequest({
            path: '/v1/peer/listPeers'
        });
    }

    async listChannels() {
        return this.makeRequest({
            path: '/v1/channel/listChannels'
        });
    }

    async getInvoices() {
        return this.makeRequest({
            path: '/v1/invoice/listInvoices'
        });
    }

    async createInvoice(amount, label = null, description = null) {
        return this.makeRequest({
            path: '/v1/invoice/genInvoice',
            method: 'POST',
            data: {
                amount,
                label: label || uuid(),
                description: description || "test-description"
            }
        });
    }

    async getRoute(pubkey, amount = 0) {
        return this.makeRequest({
            path: '/v1/network/getRoute/' + pubkey + '/' + amount
        });
    }

    async pay(invoice) {

        const inv = bolt11.decode(invoice);

        // Selfpayments must be routed manually for core-ln
        if (inv.payeeNodeKey == this.info.id) {
            const circle = await this.findCircular();
            let blockoffset = 3 + ((circle.length + 1) * 6);
            console.log(circle);
            let lastNodeId = "";
            const circleRoute = circle.map((channel, index) => ({
                id: index+1 == circle.length ? this.info.id : lastNodeId = (channel.id || (channel.destination != lastNodeId ? channel.destination : channel.source)),
                channel: channel.short_channel_id,
                direction: (index < 2) ? 1 : 0,
                amount_msat: (parseInt(inv.millisatoshis) + circle.length - index - 1).toString(),
                delay: blockoffset -= 6,
                style: 'tlv'
            }));
            console.log(circleRoute,
                inv.tagsObject.payment_hash,
                "selfpaymentlabel",
                inv.millisatoshis,
                invoice,
                inv.tagsObject.payment_secret);
            return this.rpc('sendpay', [
                circleRoute,
                inv.tagsObject.payment_hash,
                "selfpaymentlabel",
                inv.millisatoshis,
                invoice,
                inv.tagsObject.payment_secret
            ])
        }

        return this.makeRequest({
            path: '/v1/pay',
            method: 'POST',
            data: {
                invoice,
                retry_for: 20 //seconds
            }
        });
    }

    async createOffer(amount, description = null) {
        return this.makeRequest({
            path: '/v1/offers/offer',
            method: 'POST',
            data: {
                amount,
                description: description || "test-description-" + uuid()
            }
        });
    }

    async fetchOfferInvoice(offer) {
        return this.makeRequest({
            path: '/v1/offers/fetchInvoice',
            method: 'POST',
            data: {
                offer
            }
        });
    }

    async generateOnChainAddress() {
        return this.makeRequest({
            path: '/v1/newaddr',
            method: 'GET'
        });
    }

    async withdrawOnChain() {
        return this.makeRequest({
            path: '/v1/withdraw',
            method: 'POST',
            data: {

            }
        });
    }

    async rpc(method, params) {
        return this.makeRequest({
            path: '/v1/rpc',
            method: 'POST',
            data: {
                method,
                params
            }
        });
    }

    async decodeInvoice(invoice) {
        return this.makeRequest({
            path: '/v1/pay/decodePay/' + invoice,
            method: 'GET'
        });
    }

    async makeRequest(options) {

        const response = await axios({
            url: this.url + options.path,
            method: 'GET',
            httpsAgent: new https.Agent({
                rejectUnauthorized: false
            }),
            headers: {
                'macaroon': this.macaroon
            },
            ...options,
        }).catch(e => {
            console.error('LIGHTNING ERROR');
            throw e;
        });
        return response.data;
    }
}