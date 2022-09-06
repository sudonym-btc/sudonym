# sudonym

This monorepo contains all code related to the sudonym whitelabel-able bitcoin and lightning wallet. The folder structure is outlined below:

```
📦 sudonym
 ┣ 📂 api    // Contains code that runs on the backend
 ┣ 📂 app    // Contains code for the mobile app
 ┣ 📂 models // Contains any shared data structures
 ┗ 📂 ops    // Contains infrastructure as code
```

<details>
  <summary>Installation</summary>

## Tooling

  <details>
    <summary>Mac</summary>

Make sure that brew is installed

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

Follow "Next steps" install instructions to add brew to path

```bash
brew tap homebrew/core && \
brew install nvm && \
brew install --cask docker && \
open -a Docker && \ 
brew install minikube && \
brew install --cask google-cloud-sdk && \
brew install gh && \
brew install ksync && \
minikube start && \
ksync init && \

source $(brew --prefix nvm)/nvm.sh && \

nvm install 18 && \

gcloud components install kubectl && \

gcloud init && \

gh auth login && \

git clone https://github.com/sudonym-btc/sudonym.git && \ cd sudonym && \
npm install && \
npm run setup:development
  
```

  </details>

  <details>
    <summary>Linux</summary>

```bash
sudo yum install dnsmasq
systemctl start dnsmasq
systemctl enable dnsmasq
systemctl status dnsmasq
LINUX: yum install -y make gcc*
```

  </details>

<br>

[optional] for live firebase integration download/ask admin for service_account.json and store in /api

[frontend] Install Flutter:

```bash
brew install --cask flutter

# M1 CHIPS ONLY

sudo gem uninstall cocoapods
brew install cocoapods
```

</details>

<details>
<summary>Run project</summary>

## API

```bash
# Setup the backend
# Makes sure the API is launched on local cluster
npm run deploy:development
# Optionally watch the API logs and hot reload changes
npm run watch:api
```

## Frontend

To run Flutter without a backend, run in the flutter - mock profile, can be found in the Run & Debug panel.
Else, change to flutter - development

</details>

<!-- 
    brew install dnsmasq
    sudo brew services start dnsmasq
    sudo cp $(brew list dnsmasq | grep /homebrew.mxcl.dnsmasq.plist$) /Library/LaunchDaemons/
    sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
    sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
    dscacheutil -flushcache -->

<details>
<summary>Infrastructure/Cloud</summary>

## Setup

After you have installed the project locally using the instructions above, you should have logged into your Google Cloud account.

If you are the admin of an empty Google Cloud project, you can run

```bash
ops/infrastructure/setup.sh
```

The above command enables the necessary APIs in the cloud project and sets up triggers to your repo, so that deploys happen via Git commits.

Creating and merging PRs for the production and staging banches will cause deployment manager to read the specs found in the "ops" folder and roll out the changes.

</details>
