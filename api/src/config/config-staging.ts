import { sqlCloudProxy } from './config-production';

export const configStaging = () => ({
	domain: 'staging.sudonym.app',
	network: 'mainnet',
	database: sqlCloudProxy,
});
