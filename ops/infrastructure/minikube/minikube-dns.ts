import * as fs from 'fs';
import * as child_process from 'child_process';
const minikubeIp = child_process.execSync('minikube ip').toString();
console.log("minikube ip ", minikubeIp);
if (!minikubeIp) throw Error("Could not get minikube IP");

const confDnsDarwin = () => {

}
const confDnsLinux = () => {
    const confPath = '/etc/dnsmasq.conf';
    const resolvPath = '/etc/resolv.conf';
    var file = fs.readFileSync('ops/dnsmasq.conf').toString();
    file = file.replace("###MINIKUBEIP###", minikubeIp);
    var resolver = "nameserver 127.0.0.1";
    if (resolver != fs.readFileSync(resolvPath).toString().trim()) {
        child_process.execSync(`sudo chattr -f -i ${resolvPath}`);
        child_process.execSync(`sudo tee ${resolvPath} > /dev/null <<EOF
${resolver}
EOF`);
        child_process.execSync(`sudo chattr -f +i ${resolvPath}`);
    }
    if (file.trim() != fs.readFileSync(confPath).toString().trim()) {
        child_process.execSync(`sudo tee ${confPath} > /dev/null <<EOF
${file}
EOF`);
        child_process.execSync(`systemctl restart dnsmasq`);
    }
}

const confDnsWin32 = () => {
    throw new Error("Not implemented");
}


if (process.platform == "darwin") {

    confDnsDarwin();

} else if (process.platform == "linux") {

    confDnsLinux();

} else if (process.platform == "win32") {

    confDnsWin32();

}

