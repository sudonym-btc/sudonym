import { getConfig } from 'config/config';

const https = require('https');

export const fetchHttpOpts = {
	cache: 'no-store',
	headers: {
		'Cache-Control': 'no-cache',
	},
	agent: new https.Agent({
		rejectUnauthorized: !['development', 'test'].includes(getConfig().env),
	}),
};
