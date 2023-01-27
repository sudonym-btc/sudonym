import { MSATOSHIS, TRANSACTION_TAGS } from '@sudonym/models';
import { runAsUser } from 'helper/context-request';
import { PotService } from 'module/pot/pot.service';
import { Transaction } from 'module/transaction/transaction.model';
import { TransactionService } from 'module/transaction/transaction.service';
import { filter, firstValueFrom } from 'rxjs';
import { RecursivePartial } from 'sequelize-typescript/dist/shared/types';
import { bolt11Encode } from 'test/mock/classes';
import { mockEntities } from 'test/mock/create-mock-entities';
import { scaffoldTest } from 'test/mock/scaffold-test';
import { scaffoldGroup } from '../mock/scaffold-group';

scaffoldGroup('Roundup', (scaffold) => {
	const attempt = async (
		entities: mockEntities,
		tx: RecursivePartial<Transaction> = {}
	) => {
		const addr = bolt11Encode(1 * MSATOSHIS).paymentRequest;

		const t = scaffold.app.get(TransactionService).create({
			outgoing: true,
			potId: entities.pot[0].id,
			type: 'bolt11',
			currencyCode: 'BTC',
			originalAddress: addr,
			address: addr,
			amount: 1,
			...tx,
		});
		return t;
	};

	scaffoldTest(
		scaffold,
		'should not create roundup payments for roundup payments',
		async (entities) => {
			const roundUpPot = await runAsUser(entities.user[0], async () => {
				const { entity: pot } = await scaffold.app
					.get(PotService)
					.create({
						name: 'Roundup',
						currency: 'BTC',
						roundup: true,
					});
				expect(pot.PotUser.index).toBe(2);
				return pot;
			});

			attempt(entities, {
				amount: 0.5,
				currencyCode: 'USD',
				Tags: [
					{
						tagId: parseInt(
							Object.keys(TRANSACTION_TAGS).find(
								(key) => TRANSACTION_TAGS[key] == 'roundup'
							)
						),
					},
				],
			});

			await new Promise((res, rej) => {
				setTimeout(res, 1000);
				firstValueFrom(
					scaffold.app
						.get(TransactionService)
						.onAfterCreated.pipe(
							filter((x) => x.potId == roundUpPot.id)
						)
				).then(rej);
			});
		}
	);

	scaffoldTest(
		scaffold,
		'should create child payment into roundup pot',
		async (entities) => {
			const roundUpPot = await runAsUser(entities.user[0], async () => {
				const { entity: pot } = await scaffold.app
					.get(PotService)
					.create({
						name: 'Roundup',
						currency: 'BTC',
						roundup: true,
					});
				expect(pot.PotUser.index).toBe(2);
				return pot;
			});

			console.log(roundUpPot);

			attempt(entities, {
				amount: 0.5,
				currencyCode: 'USD',
			});

			await Promise.all([
				firstValueFrom(
					scaffold.app
						.get(TransactionService)
						.onAfterCreated.pipe(
							filter((x) => x.potId == roundUpPot.id)
						)
				).then((x) =>
					expect(x).toMatchObject({
						amount: 0.5,
						currencyCode: 'USD',
					})
				),
			]);
		}
	);

	scaffoldTest(
		scaffold,
		'should not send alerts for roundup payments',
		async (entities) => {}
	);
});
