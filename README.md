# sudonym monorepo

## Installation:

### Tooling

#### Mac

```
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  <!-- Follow "Next steps" install instructions to add brew to path -->

  brew tap homebrew/core && \
  brew install nvm && \
  brew install --cask docker && \
  open -a Docker && \ 
  brew install minikube && \
  brew install --cask google-cloud-sdk && \
  brew install gh && \
  
  source $(brew --prefix nvm)/nvm.sh && \

  nvm install 18 && \

  gcloud components install kubectl && \

  gcloud init && \

  gh auth login && \

  git clone https://github.com/sudonym-btc/sudonym.git && \ cd sudonym && \
  npm install && \
  npm run setup:development
  
```

[optional] for live firebase integration download/ask admin for service_account.json and store in /api

[optional] Setup the backend in minikube with hotreload and seed the DB
```
curl https://ksync.github.io/gimme-that/gimme.sh | sudo bash && \
docker build --target development -t api:latest -f api/Dockerfile . && \
minikube image load api:latest && \
npm run deploy:development && \
npm run setup:development
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
<!-- Setup the backend -->
npm run deploy:development 
<!-- Watch the API logs and hot reload -->
npm run api:logs
```

To run Flutter without a backend, run in the flutter - mock profile, can be found in the Run & Debug panel.
Else, change to flutter - development

### Linux

sudo yum install dnsmasq
systemctl start dnsmasq
systemctl enable dnsmasq
systemctl status dnsmasq

<!-- 
    brew install dnsmasq
    sudo cp $(brew list dnsmasq | grep /homebrew.mxcl.dnsmasq.plist$) /Library/LaunchDaemons/
    sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
    sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
    dscacheutil -flushcache

Download service account json for firebase and store in API root folder -->

<!-- npm run build for all folders including TS models -->


LINUX: yum install -y make gcc*
