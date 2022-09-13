import * as commandLineArgs from 'command-line-args';

const optionDefinitions = [
	{ name: 'lightning', alias: 'l', type: String },
	{ name: 'bitcoinMQ', type: String },
	{ name: 'selfUrl', type: String },
];
export const options = commandLineArgs(optionDefinitions, {
	stopAtFirstUnknown: false,
	partial: true,
});
