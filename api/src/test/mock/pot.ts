import { PotUser } from 'module/pot-user/pot-user.model';
import { Pot } from 'module/pot/pot.model';
export const createPots = async () => {
	const pots = await Pot.bulkCreate([
		{
			name: 'test',
			currency: 'BTC',
			balance: 1,
			spendableBalance: 1,
		},
	]);

	for (const pot of pots) {
		pot.PotUsers = [
			await PotUser.create({
				potId: pot.id,
				index: 1,
				userId: '123',
			}),
		];
	}

	return pots;
};
