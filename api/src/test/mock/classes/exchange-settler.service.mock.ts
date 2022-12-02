import { ExchangeSettlerService } from 'service/exchange/exchange-settler.service';

export class MockExchangeSettlerService extends ExchangeSettlerService {
	async onModuleInit(): Promise<void> {}
	buy = jest.fn(super.buy);
}
