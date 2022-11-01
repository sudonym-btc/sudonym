import * as request from 'supertest';
import { scaffoldGroup } from '../../mock/scaffold-group';

scaffoldGroup('Access Scopes', (scaffold) => {
	it('should not be able to overwrite protected columns', () => {
		// return request(scaffold.app.getHttpServer()).post('/auth').expect(401);
	});

});
