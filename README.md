# sudonym

This monorepo contains all code related to the sudonym whitelabel-able bitcoin
and lightning wallet. The folder structure is outlined below:

```text
📦 sudonym
 ┣ 📂 api    // Contains code that runs on the backend
 ┣ 📂 app    // Contains code for the mobile app
 ┣ 📂 models // Contains any shared data structures
 ┗ 📂 infrastructure    // Contains infrastructure as code
```

<details>
  <summary>Installation</summary>

## Prerequisites

Check that the `curl` command is available.
On Debian, make sure the following is installed: `sudo apt install build-essential`.

## Install

```bash
git clone https://github.com/sudonym-btc/sudonym.git && cd sudonym && \
./install.sh && \
npm run deploy:development:hard
```

You are welcome to try the install.sh script.
However you can also manually install the following tools:

- Docker
- Minikube
- Google Cloud SDK
- kubectl
- Flutter
- Github Cli
- NVM
- Python

You will need to add the installed packages to your PATH variable in order to
access them via the terminal.
Run the brew installation command again in order to find the code to
add brew to PATH if it isn't already.
Call the `brew info nvm` command to see what
you need to add to your .zshrc file for example.

To be able to use Google APIs on Flutter,
you will need to add your developer key to the firebase project.

For android development, add command-line tools in android studio to be able to
create virtual devices from VS Code.

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

To run Flutter without a backend, run in the flutter - mock profile,
can be found in the Run & Debug panel.
Else, change to flutter - development

</details>

<details>
<summary>Infrastructure/Cloud</summary>

## Setup

After you have installed the project locally using the instructions above,
you should have logged into your Google Cloud account.

If you are the admin of an empty Google Cloud project, you can run

```bash
infrastructure/setup.sh
```

The above command enables the necessary APIs in the cloud project
and sets up triggers to your repo, so that deploys happen via Git commits.

Creating and merging PRs for the production and staging banches
will cause deployment manager to read the specs found in the "infrastrcuture" folder
and roll out the changes.

The first deployment of each environment can take multiple executions
as the clusters start up and there may be race conditions.

Might have to run
`gcloud beta deployment-manager type-providers delete test-cluster-type`
if you abandon a deployment

Get kubectl credentials for cluster
`gcloud container clusters get-credentials test-cluster`

If cannot validate ingress
`kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission`

</details>
