import { LightningNodeService } from "../../service/lightning-node/lightning-node.service";
import { bech32 } from 'bech32';
import { Buffer } from 'buffer';
import fetch from 'node-fetch';
import { Inject, Injectable, Logger } from "@nestjs/common";
import { AddressParseResponse } from "@sudonym/models";

@Injectable()
export class AddressParser {

    @Inject(LightningNodeService) lightningNodeService: LightningNodeService;
    private readonly logger = new Logger(AddressParser.name);

    async parse(invoice) {
        const r: AddressParseResponse = await this.parseInvoiceHelper(invoice) as AddressParseResponse;
        r.originalInput = invoice;
        r.success = typeof r.success === "undefined" ? true : r.success;
        r.isLnUrl = typeof r.isLnUrl === "undefined" ? false : r.isLnUrl;
        r.isLnAddress = typeof r.isLnAddress === "undefined" ? false : r.isLnAddress;
        r.isBolt11 = typeof r.isBolt11 === "undefined" ? false : r.isBolt11;
        r.isBolt12 = typeof r.isBolt12 === "undefined" ? false : r.isBolt12;
        r.isOnChain = typeof r.isOnChain === "undefined" ? false : r.isOnChain;
        return r;
    }
    
    parseInvoiceHelper = async (invoice: string): Promise<Partial<AddressParseResponse>> => {
        if (!invoice || invoice === '') {
            return null;
        }

        const lcInvoice = invoice.trim().toLowerCase();
        let requestCode = lcInvoice;

        // Check if this is a Lightning Address
        if (validateInternetIdentifier(requestCode)) {
            const { success, data, message } = await this.handleLightningAddress(requestCode) as any;

            if (!success) {
                return {
                    success,
                    data: null,
                    message,
                    isLnUrl: false,
                    isLnAddress: true,
                };
            }

            return {
                data,
                isLnUrl: true,
                isLnAddress: true,
            }
        }

        // Check if Invoice has `lightning` or `lnurl` prefixes
        // (9 chars + the `:` or `=` chars) --> 10 characters total
        const hasLightningPrefix = lcInvoice.indexOf(`${LIGHTNING_SCHEME}:`) !== -1;
        if (hasLightningPrefix) {
            // Remove the `lightning` prefix
            requestCode = lcInvoice.slice(10, lcInvoice.length);
        }

        // (5 chars + the `:` or `=` chars) --> 6 characters total
        const hasLNURLPrefix = lcInvoice.indexOf(`${LNURL_SCHEME}:`) !== -1;
        if (hasLNURLPrefix) {
            // Remove the `lightning` prefix
            requestCode = lcInvoice.slice(6, lcInvoice.length);
        }

        // Parse LNURL or BOLT11
        const isLnUrl = requestCode.startsWith(LNURL_SCHEME);
        if (isLnUrl) {
            return {
                isLnUrl: true,
                data: await this.handleLNURL(requestCode)
            };
        } else {
            return {
                isLnUrl: false,
                isBolt11: true,
                data: await this.handleBOLT11(requestCode)
            };
        }
    };

    handleLNURL = (invoice: string) => {
        // Decoding bech32 LNURL
        const decodedLNURL = bech32.decode(invoice, 1500);
        const url = Buffer.from(bech32.fromWords(decodedLNURL.words)).toString();

        this.logger.debug("Fetching LnUrl from " + url);
        return fetch(url)
            .then(r => r.json())
    };

    handleLightningAddress = (internetIdentifier: string) => {
        const addressArr = internetIdentifier.split('@');

        // Must only have 2 fields (username and domain name)
        if (addressArr.length !== 2) {
            return {
                success: false,
                message: 'Invalid internet identifier format.',
            };
        }

        const [username, domain] = addressArr;

        // Must only have 2 fields (username and domain name)
        if (addressArr[1].indexOf('.') === -1) {
            return {
                success: false,
                message: 'Invalid internet identifier format.',
            };
        }

        const url = `https://${domain}/.well-known/lnurlp/${username}`;

        return fetch('https://satcors.fiatjaf.com/?url=' + encodeURIComponent(url))
            .then(r => r.json())
            .then((data: any) => {
                data.domain = domain;

                return {
                    success: true,
                    data: {
                        ...data,
                        domain,
                        username,
                    },
                }
            }).catch(_ => {
                return {
                    success: false,
                    message: 'This identifier does not support Lightning Address yet.',
                };
            });
    };

    handleBOLT11 = async (invoice: string) => {
        // Check if Invoice starts with `lnbc` prefix
        if (!invoice.includes(BOLT11_SCHEME)) {
            return null;
        }

        // Decoded BOLT11 Invoice
        const result = await this.lightningNodeService.decodeInvoice(invoice);

        return result;
    };
}


export const validateInternetIdentifier = (internetIdentifier) => {
    var re = /\S+@\S+\.\S+/;
    return re.test(internetIdentifier);
}

const LIGHTNING_SCHEME = 'lightning';
const BOLT11_SCHEME = 'lnbc';
const LNURL_SCHEME = 'lnurl';
const BOLT12_SCHEME = 'lno1';
