import { Storage } from '@google-cloud/storage';
import * as dotenv from 'dotenv';
import * as fs from 'fs';
import { getConfig } from '../config/config';
const storage = new Storage();
export const CONFIG_FOLDER = __dirname + '/../config';

// Downloads config files from google cloud project
export async function downloadFiles(
	force = false,
	alreadyDone = () =>
		['mock', 'development', 'test'].includes(getConfig().env) ||
		fs.existsSync(CONFIG_FOLDER + '/service-account.json')
) {
	// Load ignored local values before deciding whether cloud configuration is needed.
	const envFile = `${process.cwd()}/src/config/.env`;
	if (fs.existsSync(envFile)) {
		dotenv.config({ path: envFile });
	}

	console.log('Downloading files already done? ' + alreadyDone());
	if (!alreadyDone() || force) {
		const buckets = (await storage.getBuckets())[0];
		const bucket = buckets.find(
			(b) => b.name.includes('config') && b.name.includes(getConfig().env)
		);

		if (!bucket) {
			throw Error(
				'Could not find the suitable config bucket in the cloud project'
			);
		}
		const files = (await bucket.getFiles())[0];
		for (const file of files) {
			// Ignore folders
			if (file.name.split('.').length == 1) continue;
			const destination = `${CONFIG_FOLDER}/${file.name}`;

			try {
				await bucket.file(file.name).download({
					destination,
				});
				console.log(
					`gs://${bucket.name}/${file.name} downloaded to ${destination}.`
				);
			} catch (e) {
				console.error(e);
			}
		}
	}
}
if (require.main === module) {
	downloadFiles();
}
