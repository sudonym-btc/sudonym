import * as fs from 'fs';
import * as path from 'path';

function searchDir(prefix, dir) {
	const fullPath = path.join(prefix, dir);
	const files = fs.readdirSync(fullPath);

	files.forEach(file => {
		const filePath = path.join(fullPath, file);
		if (file.endsWith('.dart')) {
			let str = fs.readFileSync(filePath).toString();

			str = str.replaceAll('.push', '.add');
			str = str.replaceAll('Object', 'Map<String, dynamic>');
			str = str.replaceAll('Date ', 'DateTime ');
			str = str.replaceAll('Promise', 'Future');
			str = str.replaceAll('json["createdAt"]', 'DateTime.parse(json["createdAt"])');

			fs.writeFileSync(filePath, str);
		} else if (fs.lstatSync(fullPath).isDirectory()) {
			searchDir(fullPath, file);
		}
	});
}

const dir = __dirname + '/../../dart/lib/';
searchDir('', dir);