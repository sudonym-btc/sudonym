# sudonym monorepo

setup:

 mac: isntall homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    install nvm
    brew install nvm --> follow instructions
    nvm install 16
    brew install minikube
    <!-- Instead of using docker as default engine, hyperkit will allow ports to be forwarded more easily -->
    brew install hyperkit
    <!-- Setup local domain -->

    cp ./ops/dnsmasq.conf /usr/local/etc/dnsmasq.conf
    brew install dnsmasq
    sudo cp $(brew list dnsmasq | grep /homebrew.mxcl.dnsmasq.plist$) /Library/LaunchDaemons/
    sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
    sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
    dscacheutil -flushcache

    sudo mkdir -p /etc/resolver
    sudo tee /etc/resolver/local.app > /dev/null <<EOF
nameserver 127.0.0.1
domain local.app
search_order 1
EOF

frontend:
    flutter:
    https://docs.flutter.dev/get-started/install/macos

launch fresh:
  install gcloud
  enable deloyment manager, enable kubernetes api
  gcloud deployment-manager deployments create a-single-vm --template vm_template.jinja
