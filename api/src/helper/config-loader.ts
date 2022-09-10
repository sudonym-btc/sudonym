import { Storage } from '@google-cloud/storage';
import * as fs from 'fs';
import { getConfig } from '../config/config';
const storage = new Storage();

// Downloads config files from google cloud project
export async function downloadFiles(force = false, alreadyDone = () => fs.existsSync(process.cwd() + "/src/service-account.json")) {

    if (!alreadyDone() || force) {

        const buckets = (await storage.getBuckets())[0];
        const bucket = buckets.find(b => b.name.includes(getConfig().env));

        if (!bucket) {
            throw Error("Could not find the suitable config bucket in the cloud project");
        }

        const files = (await bucket.getFiles())[0];

        for (let file of files) {
            const destination = process.cwd() + "/src/" + file.name;
            await storage.bucket(bucket.name).file(file.name).download({
                destination
            });
            console.log(
                `gs://${bucket.name}/${file.name} downloaded to ${destination}.`
            );
        }
    }
}
if (require.main === module) {
    downloadFiles();
}