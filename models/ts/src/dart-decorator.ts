import * as fs from 'fs';

const dir = __dirname + "/../../dart/lib/base-types/";
const dirs = fs.readdirSync(dir);

/**
 * kebab-case to UpperCamelCase
 * @param {String} string
 * @return {String}
 */
function toUpperCamelCase(string) {
    return string
        .toLowerCase()
        .split('-')
        .map(it => it.charAt(0).toUpperCase() + it.substring(1))
        .join('');
}

dirs.forEach(file => {
    if (file.endsWith(".dart")) {
        const str = fs.readFileSync(dir + file).toString();
        // const newStr = str.replace("(", "({").replace(")", "})");

        // fs.writeFileSync(dir + file, newStr);

        fs.writeFileSync(dir + "../" + file, `
        import 'base-types/${file}' as Model;
        import 'base-class.dart';

        class ${toUpperCamelCase(file.substring(0, file.length - 5))} extends BaseClass {
            Map<String, dynamic> data = {};

            ${toUpperCamelCase(file.substring(0, file.length - 5))}(this.data): super(data);

            operator [](String i) => data[i];
            operator []=(String i, dynamic value) => data[i] = value;

            get(String i) {
              return this[i];
            }

            set(String i, dynamic val) {
                this[i] = val;
            }

            Map<String, dynamic> toJson() => data;
        }

        `);

        fs.copyFileSync(dir + "index.dart", dir + "../index.dart");
    }
});


// import 'base-types/pot.dart' as ModelPot;

// class Pot {

//   Map<String, dynamic> data = {}

//   Pot(this.data) {}


//   operator [](String i) => _data[i];
//   operator []=(String i, int value) => _data[i] = value;

//   get(String i) {
//     return this[i];
//   }
// }
