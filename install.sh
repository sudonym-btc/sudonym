if [ "$(uname)" = "Darwin" ] || [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew tap homebrew/core
    brew install nvm minikube gh ksync python jq

    if [ "$(uname)" = "Darwin" ]; then

        brew tap homebrew/cask
        brew install --cask flutter docker google-cloud-sdk
        open -a Docker
        gcloud components install kubectl
        # Oly necessary for M1 chips
        sudo gem uninstall cocoapods
        brew install cocoapods

    elif [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
        sudo snap install kubectl google-cloud-cli flutter android-studio --classic
        sudo snap install docker --devmode
        brew install gcc
        # sudo snap connect docker:home
        # sudo addgroup --system docker
        # sudo adduser $USER docker
        # newgrp docker
        # sudo snap disable docker
        # sudo snap enable docker
    fi
    # Do something under GNU/Linux platform
    # elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    #     # Do something under 32 bits Windows NT platform
    # elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    # Do something under 64 bits Windows NT platform
fi

. $(brew --prefix nvm)/nvm.sh
nvm install 18
npm install

gcloud init
gcloud auth application-default login
project=$(gcloud config get project)
export GCLOUD_PROJECT=$project
(cd api && npm run getConfig)

(cd ops/infrastructure/minikube && pip3 install -r requirements.txt)
