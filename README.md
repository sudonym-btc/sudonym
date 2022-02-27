# sudonym monorepo

setup:

 mac: isntall homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    install nvm
    brew install nvm --> follow instructions
    nvm install 16
    brew install minikube

frontend:
    flutter:
    https://docs.flutter.dev/get-started/install/macos

launch fresh:
  install gcloud
  enable deloyment manager, enable kubernetes api
  gcloud deployment-manager deployments create a-single-vm --template vm_template.jinja
