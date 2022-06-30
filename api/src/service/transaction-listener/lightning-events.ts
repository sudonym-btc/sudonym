import { Inject, Injectable } from "@nestjs/common";
import { getConfig } from "src/config/config";
import * as fs from 'fs';
import * as WebSocket from 'ws';
import { Subject } from "rxjs";
import { LightningNodeService } from "../lightning-node/lightning-node.service";

@Injectable()
export class LightningEvents {

    @Inject() LightningNodeService: LightningNodeService;
    private macaroon = Buffer.from(fs.readFileSync(getConfig().macaroonFile)).toString("base64");
    private url = getConfig().lightningREST.replace('https', 'wss');
    public onEvent = new Subject();

    onModuleInit() {

        console.log("Connecting to lightning message queue at " + this.url);
        
        // const ws = new WebSocket(this.url + "/v1/ws", [this.macaroon, 'json'], {
        const ws = new WebSocket(this.url + "/v1/ws", ['json'], {
            rejectUnauthorized: false,
            headers: {
                'sec-websocket-protocol': this.macaroon
            }
        })

        ws.on('message', data => {
            data = JSON.parse(data);
            if (data.type == "Buffer") {
                data.data = Buffer.from(data.data);
            }
            console.log('received: %s', data.data);
            this.onEvent.next(data);
        });

        ws.on('error', function error(data) {
            console.error('error: %s', data);
        });


        this.onEvent.subscribe(e => {
            console.log("EVENT", e);
        });
    }

}
