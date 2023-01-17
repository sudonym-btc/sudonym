import { User } from 'module/user/user.model';
import { Sequelize } from 'sequelize-typescript';
export const createPots = async (db: Sequelize, users: User[]) => {
	const pots = await db.model('Pot').bulkCreate([
		{
			name: 'test',
			currency: 'BTC',
			balance: 1,
			spendableBalance: 1,
		},
	]);

	for (const pot of pots) {
		(pot as any).PotUsers = [
			await db.model('PotUser').create({
				potId: pot.id,
				index: 1,
				userId: users[0].id,
			}),
		];
	}

	return pots;
};
