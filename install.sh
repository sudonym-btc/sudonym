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
        sudo snap install kubectl --classic
        sudo snap install google-cloud-cli --classic
        sudo snap install flutter --classic
        sudo snap install android-studio --classic
        brew install gcc

        # sudo apt-get install libcanberra-gtk3-module
        # sudo apt-get install libcanberra-gtk-module:i386
        # sudo apt-get install libcanberra-gtk-module
        sudo apt update
        sudo apt-get install \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo apt-key fingerprint 0EBFCD88
        sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io
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

(cd infrastructure/minikube && pip3 install -r requirements.txt)