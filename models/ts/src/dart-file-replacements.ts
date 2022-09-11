import * as fs from 'fs';

const dir = __dirname + "/../../dart/lib/base-types/";
const dirs = fs.readdirSync(dir);

dirs.forEach(file => {
    if (file.endsWith(".dart")) {
        let str = fs.readFileSync(dir + file).toString();
        
        str = str.replaceAll('.push', '.add');
        str = str.replaceAll('Object', 'Map<String, dynamic>');
        str = str.replaceAll('Date ', 'DateTime ');
        str = str.replaceAll('Promise', 'Future');
        str = str.replaceAll('json["createdAt"]', 'DateTime.parse(json["createdAt"])');

        fs.writeFileSync(dir + file, str);
    }
});