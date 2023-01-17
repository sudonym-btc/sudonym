import { runAsUser } from 'helper/context-request';
import { CurrencyService } from 'module/currency/currency.service';
import { PotUser } from 'module/pot-user/pot-user.model';
import { PotUserService } from 'module/pot-user/pot-user.service';
import { PotService } from 'module/pot/pot.service';
import { scaffoldGroup } from './mock/scaffold-group';
import { scaffoldTest } from './mock/scaffold-test';

scaffoldGroup('Pot', (scaffold) => {
	scaffoldTest(scaffold, 'should create pot', async (entities) => {
		// Create a second pot
		await runAsUser(entities.user[0], async () => {
			const { entity: pot } = await scaffold.app.get(PotService).create({
				name: 'Test 2',
				currency: 'BTC',
			});
			expect(pot.PotUser.index).toBe(2);
		});
	});
	scaffoldTest(scaffold, 'should delete pot', async (entities) => {
		// Create a second pot
		await runAsUser(entities.user[0], async () => {
			const { entity: pot } = await scaffold.app.get(PotService).create({
				name: 'Test 2',
				currency: 'BTC',
			});
			expect(pot.PotUser.index).toBe(2);

			await scaffold.app.get(PotService).delete(entities.pot[0].id);

			expect(
				(
					await PotUser.findOne({
						where: {
							potId: pot.id,
						},
					})
				).index
			).toBe(1);
		});
	});

	scaffoldTest(
		scaffold,
		'should change currency of pot',
		async (entities) => {
			const prevSpendable = entities.pot[0].spendableBalance;
			const prevBalance = entities.pot[0].balance;

			const newSpendable = await scaffold.app
				.get(CurrencyService)
				.convert(entities.pot[0].currency, 'USD', prevSpendable);
			const newBalance = await scaffold.app
				.get(CurrencyService)
				.convert(entities.pot[0].currency, 'USD', prevBalance);

			const { entity: pot } = await scaffold.app
				.get(PotService)
				.update(entities.pot[0].id, {
					currency: 'USD',
				});
			expect(pot.spendableBalance).toBe(newSpendable.amount);
			expect(pot.balance).toBe(newBalance.amount);
		}
	);

	scaffoldTest(
		scaffold,
		'should not allow delete if last pot',
		async (entities) => {
			// Todo should also not delete when triggered by code, not user
			await runAsUser(entities.user[0], async () => {
				await expect(
					scaffold.app.get(PotService).delete(entities.pot[0].id)
				).rejects.toThrowError();
			});
		}
	);

	scaffoldTest(
		scaffold,
		'should not allow duplicate name',
		async (entities) => {
			// Create a second pot
			await runAsUser(entities.user[0], async () => {
				await expect(
					scaffold.app.get(PotService).create({
						name: entities.pot[0].name,
						currency: 'BTC',
					})
				).rejects.toThrow();
			});
		}
	);

	scaffoldTest(scaffold, 'should reorder up', async (entities) => {
		// Create a second pot
		await runAsUser(entities.user[0], async () => {
			const { entity: pot } = await scaffold.app.get(PotService).create({
				name: 'Test 2',
				currency: 'BTC',
			});
			expect(pot.PotUser.index).toBe(2);

			expect(
				(
					await scaffold.app
						.get(PotUserService)
						.update(entities.pot[0].PotUsers[0].id, {
							index: 2,
						})
				).entity.index
			).toBe(2);
			expect((await PotUser.findByPk(pot.PotUser.id)).index).toBe(1);
		});
	});

	scaffoldTest(scaffold, 'should reorder down', async (entities) => {
		// Create a second pot
		await runAsUser(entities.user[0], async () => {
			const { entity: pot2 } = await scaffold.app.get(PotService).create({
				name: 'Test 2',
				currency: 'BTC',
			});
			expect(pot2.PotUser.index).toBe(2);

			const { entity: pot3 } = await scaffold.app.get(PotService).create({
				name: 'Test 3',
				currency: 'BTC',
			});
			expect(pot3.PotUser.index).toBe(3);

			expect(
				(
					await scaffold.app
						.get(PotUserService)
						.update(pot3.PotUser.id, {
							index: 2,
						})
				).entity.index
			).toBe(2);

			expect(
				(await PotUser.findByPk(entities.pot[0].PotUsers[0].id)).index
			).toBe(1);

			expect((await PotUser.findByPk(pot2.PotUser.id)).index).toBe(3);
		});
	});
});
