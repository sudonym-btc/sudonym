import { Action } from '../action';
import { WithdrawRequest } from '../withdraw-request';
import { PaymentRequest } from '../payment-request';
import { Bolt11 } from '../bolt11';
import { ActionRemoteResponse } from '../action-remote-response';
export interface IAddressParser {
	parse(address: string): Promise<Action>;
	fetchRemoteLnUrl(invoice: string): Promise<ActionRemoteResponse<WithdrawRequest>
		| ActionRemoteResponse<PaymentRequest>>;
	fetchRemoteLightningAddress(
		internetIdentifier: string
	): Promise<ActionRemoteResponse<PaymentRequest>>;
	fetchBolt11(invoice: string): Promise<ActionRemoteResponse<Bolt11>>;
	getType(address: string): [string, string];
}
