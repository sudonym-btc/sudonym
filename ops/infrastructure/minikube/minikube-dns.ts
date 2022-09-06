import * as fs from 'fs';
import * as child_process from 'child_process';

const minikubeIp = child_process.execSync('minikube ip').toString();
console.log("Binding local addresses to minikube IP ", minikubeIp);

if (!minikubeIp) throw Error("Could not get minikube IP");

const localConfPath = "ops/infrastructure/minikube/dnsmasq.conf"
var dnsmasqConfFile = fs.readFileSync(localConfPath).toString();
var file = dnsmasqConfFile.replace("###MINIKUBE###", `server=/local.development/${minikubeIp}`);

const confDnsDarwin = () => {

    const confPath = "/opt/homebrew/etc/dnsmasq.conf";//child_process.execSync('brew list dnsmasq | grep /dnsmasq.conf').toString().trim();
    const resolvPath = '/etc/resolv.conf'; ///private/etc/dnsmasq.conf ///opt/homebrew/etc/dnsmasq.conf ///opt/homebrew/Cellar/dnsmasq/2.86/.bottle/etc/dnsmasq.conf
    file = dnsmasqConfFile.replace("###MINIKUBE###", "address=/.local.development/127.0.0.1");
    
    if(!fs.existsSync(confPath)) {
        child_process.execSync("sudo touch " + confPath);
    }
    
    var resolver = "nameserver 127.0.0.1";
    if (resolver != fs.readFileSync(resolvPath).toString().trim()) {
        child_process.execSync(`sudo chflags nouchg ${resolvPath}`);
        child_process.execSync(`sudo tee ${resolvPath} > /dev/null <<EOF
${resolver}
EOF`);
        child_process.execSync(`sudo chflags uchg ${resolvPath}`);
    }
    if (file.trim() != fs.readFileSync(confPath).toString().trim()) {
        child_process.execSync(`sudo tee ${confPath} > /dev/null <<EOF
${file}
EOF`);
        child_process.execSync(`sudo brew services restart dnsmasq`);
    }
}
const confDnsLinux = () => {
    const confPath = '/etc/dnsmasq.conf';
    const resolvPath = '/etc/resolv.conf';

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

