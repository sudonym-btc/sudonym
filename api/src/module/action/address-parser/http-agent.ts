import { getConfig } from 'config/config';

const https = require('https');

export const fetchHttpOpts = {
	agent: new https.Agent({
		rejectUnauthorized: getConfig().env != 'development',
	}),
};
