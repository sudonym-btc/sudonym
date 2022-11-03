import { ActionService } from 'module/action/action.service';

export class MockActionService extends ActionService {
	async getCallback(callback: any, params: any) {
		if (callback.includes('lnurlw')) {
			return { status: 'OK' };
		}
	}
}
