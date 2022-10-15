import { Model } from 'sequelize-typescript';
import { FindOptions } from 'sequelize/types';

export class BaseModel extends Model {
	static scopes: {
		[key: string]: () => FindOptions;
	} = {};

	static accessors: {
		canFind?: any;
		canEdit?: any;
	} = {};

	toJson(): any {
		return super.toJSON();
	}
}
