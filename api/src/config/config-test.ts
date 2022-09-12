// import { options } from 'src/command-line-args';
// import { options as cmdargs } from './command-line-args';
import {v4 as uuid} from 'uuid';

export const config = {
	database: {
		name: 'app-' + uuid().substring(0,8),
		dialect: 'sqlite'
	}
};