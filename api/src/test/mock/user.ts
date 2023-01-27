import { Sequelize } from 'sequelize-typescript';

export const createUsers = (db: Sequelize) => {
	return db.model('User').bulkCreate(
		[0].map((e) => {
			const id = Math.random().toString().replace('.', '');
			return {
				id,
				firebaseId: id,
				lightningAddress: 'test',
			};
		})
	);
};

export const createUserDevices = (db: Sequelize, users: any[]) => {
	return db.model('UserDevice').bulkCreate(
		users.map((e) => {
			const id = Math.random().toString().replace('.', '');
			return {
				token: id,
				uid: e.id,
			};
		})
	);
};
