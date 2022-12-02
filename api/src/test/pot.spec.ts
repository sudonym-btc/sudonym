import { context } from 'helper/context-request';
import { CurrencyService } from 'module/currency/currency.service';
import { PotUser } from 'module/pot-user/pot-user.model';
import { PotUserService } from 'module/pot-user/pot-user.service';
import { PotService } from 'module/pot/pot.service';
import { runAsUser, scaffoldGroup } from './mock/scaffold-group';

scaffoldGroup('Pot', (scaffold) => {
	it('should create pot', async () => {
		// Create a second pot
		await runAsUser(scaffold.entities.user[0], async () => {
			let pot = await scaffold.app.get(PotService).create({
				name: 'Test 2',
				currency: 'BTC',
			});
			expect(pot.PotUsers[0].index).toBe(2);
		});
	});
	it('should delete pot', async () => {
		// Create a second pot
		await runAsUser(scaffold.entities.user[0], async () => {
			let pot = await scaffold.app.get(PotService).create({
				name: 'Test 2',
				currency: 'BTC',
			});
			expect(pot.PotUsers[0].index).toBe(2);

			await scaffold.app
				.get(PotService)
				.delete(scaffold.entities.pot[0].id);

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

	it('should change currency of pot', async () => {
		const prevSpendable = scaffold.entities.pot[0].spendableBalance;
		const prevBalance = scaffold.entities.pot[0].balance;

		const newSpendable = await scaffold.app
			.get(CurrencyService)
			.convert(scaffold.entities.pot[0].currency, 'USD', prevSpendable);
		const newBalance = await scaffold.app
			.get(CurrencyService)
			.convert(scaffold.entities.pot[0].currency, 'USD', prevBalance);

		const pot = await scaffold.app
			.get(PotService)
			.update(scaffold.entities.pot[0].id, {
				currency: 'USD',
			});
		expect(pot.spendableBalance).toBe(newSpendable.amount);
		expect(pot.balance).toBe(newBalance.amount);
	});

	it('should not allow delete if last pot', async () => {
		expect(
			scaffold.app.get(PotService).delete(scaffold.entities.pot[0].id)
		).rejects.toThrowError();
	});

	it('should not allow duplicate name', async () => {
		// Create a second pot
		await runAsUser(scaffold.entities.user[0], async () => {
			expect(scaffold.app.get(PotService).create({
				name: scaffold.entities.pot[0].name,
				currency: 'BTC',
			})).rejects.toThrow();
		});
	});

	it('should reorder up', async () => {
		// Create a second pot
		await context.runAndReturn(async () => {
			const req = {
				auth: {
					uid: scaffold.entities.user[0].id,
				},
			};

			context.set('request', req);

			const pot = await scaffold.app.get(PotService).create({
				name: 'Test 2',
				currency: 'BTC',
			});
			expect(pot.PotUsers[0].index).toBe(2);

			expect(
				(
					await scaffold.app
						.get(PotUserService)
						.update(scaffold.entities.pot[0].PotUsers[0].id, {
							index: 2,
						})
				).index
			).toBe(2);
			expect((await PotUser.findByPk(pot.PotUsers[0].id)).index).toBe(1);
		});
	});

	it('should reorder down', async () => {
		// Create a second pot
		await context.runAndReturn(async () => {
			const req = {
				auth: {
					uid: scaffold.entities.user[0].id,
				},
			};

			context.set('request', req);

			const pot2 = await scaffold.app.get(PotService).create({
				name: 'Test 2',
				currency: 'BTC',
			});
			expect(pot2.PotUsers[0].index).toBe(2);

			const pot3 = await scaffold.app.get(PotService).create({
				name: 'Test 3',
				currency: 'BTC',
			});
			expect(pot3.PotUsers[0].index).toBe(3);

			expect(
				(
					await scaffold.app
						.get(PotUserService)
						.update(pot3.PotUsers[0].id, {
							index: 2,
						})
				).index
			).toBe(2);

			expect(
				(
					await PotUser.findByPk(
						scaffold.entities.pot[0].PotUsers[0].id
					)
				).index
			).toBe(1);

			expect((await PotUser.findByPk(pot2.PotUsers[0].id)).index).toBe(3);
		});
	});
});
