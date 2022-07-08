import * as fs from 'fs';
import * as child_process from 'child_process';
const minikubeIp = child_process.execSync('minikube ip').toString();
console.log("minikube ip ", minikubeIp);
if (!minikubeIp) throw Error("Could not get minikube IP");

const confDnsDarwin = () => {

}
const confDnsLinux = () => {
    const confPath = '/etc/dnsmasq.conf';
    var file = fs.readFileSync('ops/dnsmasq.conf').toString();
    file = file.replace("###MINIKUBEIP###", minikubeIp);
    child_process.execSync(`sudo tee /etc/resolv.conf > /dev/null <<EOF
nameserver 127.0.0.1
EOF`);
child_process.execSync("sudo chattr -f +i /etc/resolv.conf");
    child_process.execSync(`sudo tee ${confPath} > /dev/null <<EOF
${file}
EOF`);
child_process.execSync(`systemctl restart dnsmasq`);
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

