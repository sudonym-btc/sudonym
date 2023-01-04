import { JwtService } from '@nestjs/jwt';
import { MSATOSHIS } from '@sudonym/models';
import { runAsUser } from 'helper/context-request';
import { CurrencyService } from 'module/currency/currency.service';
import { TransactionService } from 'module/transaction/transaction.service';
import { User } from 'module/user/user.model';
import { UserService } from 'module/user/user.service';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import * as request from 'supertest';
import waitForExpect from 'wait-for-expect';
import { exampleInvoice } from './bill-split.spec';
import { scaffoldGroup } from './mock/scaffold-group';

scaffoldGroup('Security', (scaffold) => {
	const createNewUser = (user: Partial<User>) => {
		return scaffold.app.get(UserService).create({
			firebaseId: 'abcdefg',
			id: 'abcdefg',
			...user,
		});
	};
	const outgoingTransaction = (params = {}) => ({
		potId: scaffold.entities.pot[0].id,
		type: 'lnurl',
		originalAddress: 'lnurl23423',
		address: exampleInvoice,
		currencyCode: 'BTC',
		amount: 0.001,
		outgoing: true,
		...params,
	});
	it('should only be able to create transactions for own user', async () => {
		const newUser = {
			id: 'abcdefg',
		};
		const { entity: user2 } = await runAsUser(newUser, async () =>
			createNewUser(newUser)
		);

		const data = await request(scaffold.app.getHttpServer())
			.post('/transaction')
			.set({
				'x-access-token': scaffold.app
					.get(JwtService)
					.sign({ uid: user2.id }),
			})
			.send({
				...outgoingTransaction(),
				currencyCode: 'BTC',
				amount: 0.001,
			});

		expect(data.statusCode).toBe(403);
	});

	it('should not be able to access create endpoint when not authed', async () => {
		const data = await request(scaffold.app.getHttpServer())
			.post('/transaction')
			.send({
				...outgoingTransaction(),
				currencyCode: 'BTC',
				amount: 0.001,
			});

		expect(data.statusCode).toBe(403);
	});

	it('should not be able to spend more than in pot', async () => {
		await runAsUser(scaffold.entities.user[0], async () => {
			expect(
				scaffold.app.get(TransactionService).create({
					...outgoingTransaction(),
					currencyCode: 'BTC',
					amount: 2,
				})
			).rejects.toThrowError(); //BalanceLowError
		});
	});

	it('should convert GBP transaction to BTC before sending', async () => {
		const { entity: transaction } = await runAsUser(
			scaffold.entities.user[0],
			async () => {
				return scaffold.app.get(TransactionService).create({
					...outgoingTransaction(),
					amount: 1,
					currencyCode: 'GBP',
				});
			}
		);

		const btcAmount = (
			await scaffold.app
				.get(CurrencyService)
				.convert(transaction.currencyCode, 'BTC', transaction.amount)
		).amount;

		await waitForExpect(() => {
			expect(
				(scaffold.app.get(LightningNodeService).pay as jest.Mock).mock
					.calls.length
			).toBe(1);

			expect(
				(scaffold.app.get(LightningNodeService).pay as jest.Mock).mock
					.calls[0][1]
			).toBe(Math.ceil(btcAmount * MSATOSHIS));
		});
	});
});
