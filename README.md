# sudonym monorepo

## Installation:

### Tooling

#### Mac

```
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  <!-- Add brew to path -->

  brew tap homebrew/core

  brew install nvm
  brew install --cask docker
  open Applications/Docker   <!-- Launches docker  -->
  brew install minikube
  brew install --cask google-cloud-sdk
  brew install gh
  
  source $(brew --prefix nvm)/nvm.sh

  nvm install 16

  gcloud components install kubectl

  gcloud init

  git clone git@github.com:sudonym-btc/sudonym.git && cd sudonym && npm install

  (cd api && npm run seed)
```

[optional] for live firebase integration download/ask admin for service_account.json and store in /api

[optional] Setup lightning nodes locally in regtest mode
```
npm run deploy:development && (cd ./ops/infrastructure && ./setup-test.sh)
```

[frontend] Install Flutter: 
```
brew install --cask flutter

<!-- M1 CHIPS ONLY-->

sudo gem uninstall cocoapods
brew install cocoapods
```

## Run project

```
npm run deploy:development
```

To run Flutter without a backend, run in the flutter - mock profile, can be found in the Run & Debug panel.
Else, change to flutter - development

```
npm run deploy:development # Launches minikube containers for backend
npm run api:development # Launches API with minikube parameter
```


<!-- 
    brew install hyperkit

    <!-- install gcloud On Linux download archv and unzip to be able to install components

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

Download service account json for firebase and store in API root folder -->

<!-- npm run build for all folders including TS models -->




LINUX: yum install -y make gcc*
