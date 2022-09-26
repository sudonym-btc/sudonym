import { User } from '../../module/user/user.model';

export const createUsers = () => {
	return User.bulkCreate([
		{
			id: '123',
			firebaseId: '123',
		},
	]);
};
