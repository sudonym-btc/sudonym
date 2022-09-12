import * as fs from 'fs';

import * as mocksImport from './index';
const mocks = mocksImport;

fs.writeFileSync(__dirname + '/data.json', JSON.stringify(mocks), 'utf8');
fs.writeFileSync(
	'dart/lib/mock/data.dart',
	`final json='''${JSON.stringify(mocks)}''';`,
	'utf8'
);
