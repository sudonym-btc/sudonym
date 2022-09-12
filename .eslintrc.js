module.exports = {
	'env': {
		'browser': true,
		'es2021': true
	},
	'extends': [
		'eslint:recommended',
		'plugin:@typescript-eslint/recommended',
		"prettier",
		"plugin:prettier/recommended"

	],
	'parser': '@typescript-eslint/parser',
	'parserOptions': {
		'ecmaVersion': 12,
		'sourceType': 'module',
		'project': 'tsconfig.json',
	},
	'plugins': [
		'@typescript-eslint',
		"prettier"
	],
	'rules': {
		'linebreak-style': [
			'error',
			'unix'
		],
		'quotes': [
			'error',
			'single'
		],
		'semi': [
			'error',
			'always'
		],
		"no-console": 1,       // Means warning
		"prettier/prettier": 2 // Means error
	}
};
