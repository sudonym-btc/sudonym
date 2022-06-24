import * as https from 'https';
import * as fs from 'fs';
import axios from 'axios';
import * as WebSocket from 'ws';
import { BitcoinListener } from './bitcoin-listener';
import { getConfig } from '../../config/config';
import { Inject, Injectable } from '@nestjs/common';
import { v4 as uuid } from 'uuid';

@Injectable()
export class LightningService {

    private macaroon;
    private macaroonFile = './certs/access.macaroon';
    private url = getConfig().lightningREST;

    @Inject() private bitcoinListener: BitcoinListener;

    onModuleInit() {

        this.macaroon = Buffer.from(fs.readFileSync(this.macaroonFile)).toString("base64");
        // const ws = new WebSocket(this.url.replace('https', 'wss') + "/v1/ws", [this.macaroon, 'json'], {
        const ws = new WebSocket(this.url.replace('https', 'wss') + "/v1/ws", ['json'], {
            rejectUnauthorized: false,
            headers: {
                'sec-websocket-protocol': this.macaroon
            }
        });

        ws.on('message', function message(data) {
            data = JSON.parse(data);
            if(data.type == "Buffer") {
                data.data = Buffer.from(data.data);
            }
            console.log('received: %s', data.data);
        });

        ws.on('error', function error(data) {
            console.error('error: %s', data);
        });

        this.bitcoinListener.start();
    }

    async getInfo() {
        return this.makeRequest({
            path: '/v1/getinfo'
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

    async getRoute(pubkey) {
        return this.makeRequest({
            path: '/v1/network/getRoute/' + pubkey + '/' + 1000
        });
    }

    async pay(invoice) {
        console.log(invoice);
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