import { Storage } from '@google-cloud/storage';
import * as fs from 'fs';
import { getConfig } from '../config/config';
const storage = new Storage();
import * as dotenv from 'dotenv';

// Downloads config files from google cloud project
export async function downloadFiles(
	force = false,
	alreadyDone = () =>
		["mock", "development"].includes(getConfig().env) && fs.existsSync(process.cwd() + '/src/config/service-account.json')
) {
	console.log("Downloading files already done? " + alreadyDone());
	if (!alreadyDone() || force) {
		const buckets = (await storage.getBuckets())[0];
		const bucket = buckets.find((b) =>
			b.name.includes('config') && b.name.includes(getConfig().env)
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
			const destination = `${process.cwd()}/src/config/${file.name}`;

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

	/**
	 * Set environment variables if a .env file is found
	 */
	const envFile = `${process.cwd()}/src/config/.env`;
	if (fs.existsSync(envFile)) {
		console.log("Setting env");
		dotenv.config({
			path: envFile
		});
	}
}
if (require.main === module) {
	downloadFiles();
}
