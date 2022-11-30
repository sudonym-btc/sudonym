import { AxiosRequestConfig } from 'axios';
import { getConfig } from 'config/config';
import * as https from 'https';

export const fetchHttpOpts: AxiosRequestConfig = {
	headers: {
		'Cache-Control': 'no-cache',
		Pragma: 'no-cache',
		Expires: '0',
	},
	httpsAgent: new https.Agent({
		rejectUnauthorized: !['development', 'test'].includes(getConfig().env),
	}),
};
