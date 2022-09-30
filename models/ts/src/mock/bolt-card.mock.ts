import faker from '@faker-js/faker';
import { BoltCard, Sender } from 'classes';
import * as Factory from 'factory.ts';

export const factory = Factory.Sync.makeFactory<BoltCard>(
    ({
        id: 1,
        userId: '123',
        name: 'test card',
        written: 1,
        senderId: 1,
        sender: {
            id: 1,
            potId: null,
            type: 'lnurl',
            limitMax: 1,
            limitMin: 0,
            userId: '123',
            data: 'lnurl23456789hghj',
            lnurlId: 'zxcvb-bvc',
            createdAt: new Date()
        }
    } as any)
);
export const mocks = factory.buildList(1);
