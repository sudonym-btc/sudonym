import * as fs from 'fs';
import * as child_process from 'child_process';

const minikubeIp = child_process.execSync('minikube ip').toString().trim();
console.log('Binding local addresses to minikube IP ', minikubeIp);

if (!minikubeIp) throw Error('Could not get minikube IP');

const hostsFile = '/etc/hosts';

const confDnsLinux = () => {
	child_process.execSync(`sudo tee ${hostsFile} > /dev/null <<EOF
    ${
		child_process
			.execSync(`sudo cat ${hostsFile}`)
			.toString()
			.trim()
			.split('#MINIKUBE')[0]
	}
#MINIKUBE
${minikubeIp.trim()} local.development
${minikubeIp.trim()} api.local.development
${minikubeIp.trim()} rtl.local.development
EOF`);
};
const confDnsDarwin = confDnsLinux;

const confDnsWin32 = () => {
	throw new Error('Not implemented');
};

if (process.platform == 'darwin') {
	confDnsDarwin();
} else if (process.platform == 'linux') {
	confDnsLinux();
} else if (process.platform == 'win32') {
	confDnsWin32();
}
