import { ExchangeService } from 'service/exchange/exchange.service';

export class MockExchangeService extends ExchangeService {
	async onModuleInit(): Promise<void> {}
}
