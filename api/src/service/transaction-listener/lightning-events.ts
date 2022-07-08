import { Inject, Injectable, Logger } from "@nestjs/common";
import { getConfig } from "src/config/config";
import * as fs from 'fs';
import * as WebSocket from 'ws';
import { Subject } from "rxjs";
import { LightningNodeService } from "../lightning-node/lightning-node.service";

@Injectable()
export class LightningEvents {

    private readonly logger = new Logger(LightningEvents.name);

    @Inject() LightningNodeService: LightningNodeService;
    private macaroon = Buffer.from(fs.readFileSync(getConfig().macaroonFile)).toString("base64");
    private url = getConfig().lightningREST.replace('https', 'wss');
    public onEvent = new Subject();

    onModuleInit() {

        this.logger.verbose("Connecting to lightning message queue at " + this.url);

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
            this.logger.verbose('received: %s', data.data);
            this.onEvent.next(data);
        });

        ws.on('error', function error(data) {
            this.logger.error('error: %s', data);
        });


        this.onEvent.subscribe(e => {
            this.logger.verbose("EVENT", e);
        });
    }

}
