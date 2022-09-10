/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew tap homebrew/core
brew install nvm minikube gh ksync dnsmasq python

if [ "$(uname)" = "Darwin" ]; then
    brew tap homebrew/cask
    brew install --cask flutter
    brew install --cask docker
    open -a Docker
    brew install --cask google-cloud-sdk
    gcloud components install kubectl 
    # M1 chips only
    sudo gem uninstall cocoapods
    brew install cocoapods
elif [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
    sudo snap install google-cloud-cli --classic
    sudo snap install kubectl --classic
    brew install gcc
    sudo snap install flutter --classic
    sudo snap install docker
    sudo snap install android-studio --classic
    # Do something under GNU/Linux platform
# elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
#     # Do something under 32 bits Windows NT platform
# elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    # Do something under 64 bits Windows NT platform
fi

. $(brew --prefix nvm)/nvm.sh
nvm install 18
npm install

gcloud auth application-default login
project=$(gcloud config get project)
export GCLOUD_PROJECT=$project
(cd api && npm run getConfig)
(cd ops/infrastructure/minikube && pip3 install -r requirements.txt)
