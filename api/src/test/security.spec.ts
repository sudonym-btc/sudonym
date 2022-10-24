import { scaffoldGroup } from './mock/scaffold-group';
import * as request from 'supertest';

scaffoldGroup('Security', (scaffold) => {

	it('should only be able to create transactions for own user', async () => {
		
	});

	it('should not be able to spend more than in pot', async () => {
		
	});

});