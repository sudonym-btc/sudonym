import { Config, getConfig } from '../config/config';

export const configProviders = [
    {
        provide: Config,
        useFactory: getConfig
    }];