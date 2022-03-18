// ./backends/custom.js

import { LightningBackend } from 'lnurl';

export class Backend extends LightningBackend {

	constructor(options) {
		super('custom', options, {
			defaultOptions: {
				nodeUri: 'node-uri',
			},
			requiredOptions: ['nodeUri'],
		});
	}

	checkOptions(options) {
		// This is called by the constructor.
		// Throw an error if any problems are found with the given options.
	}

	getNodeUri() {
		return Promise.resolve((this as any).options.nodeUri);
	}

	openChannel(remoteId, localAmt, pushAmt, makePrivate) {
		return Promise.reject('Not implemented');
	}

	payInvoice(invoice) {
		return Promise.reject('Not implemented');
	}

	addInvoice(amount, extra) {
		return Promise.reject('Not implemented');
	}

	getInvoiceStatus(paymentHash) {
		return Promise.reject('Not implemented');
	}
}

module.exports = Backend;




// const apiKey = {
//     id: 'b6cb8e81e3',
//     key: '74a8f70391e48b7a35c676e5e448eda034db88c654213feff7b80228dcad7fa0',
//     encoding: 'hex',
//   };
//   const server = lnurl.createServer({
//     endpoint: '/lnurl',
//     host: 'localhost',
//     port: 3001,
//     listen: true,
//     lightning: {
//       backend: {
//         path: __dirname + '/module/lightning/lnurl/custom-backend.js',
//         config: {
//         },
//       }
//     },
//     auth: {
//       apiKeys: [
//         apiKey
//       ],
//     },
//   });

//   const tag = 'payRequest';
//   const params = {
//     minSendable: 10000,
//     maxSendable: 200000,
//     metadata: '[["text/plain", "lnurl-node"]]',
//     commentAllowed: 500,
//   };
//   const options = {
//     baseUrl: 'http://localhost:3001/lnurl',
//     encode: false,
//   };
//   const signedUrl = await server.generateNewUrl(tag, params);



//   console.log((signedUrl));
