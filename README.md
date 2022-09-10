# sudonym

This monorepo contains all code related to the sudonym whitelabel-able bitcoin
and lightning wallet. The folder structure is outlined below:

```text
📦 sudonym
 ┣ 📂 api    // Contains code that runs on the backend
 ┣ 📂 app    // Contains code for the mobile app
 ┣ 📂 models // Contains any shared data structures
 ┗ 📂 ops    // Contains infrastructure as code
```

<details>
  <summary>Installation</summary>

```bash
git clone https://github.com/sudonym-btc/sudonym.git && \ cd sudonym && \
./install.sh && \
npm run deploy:development:hard  
```

You will need to add the installed packages to your PATH variable in order to
access them via the terminal.
Call the `brew info nvm` command to see what
you need to add to your .zshrc file for example.

To be able to use Google APIs on Flutter,
you will need to add your developer key to the firebase project.

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

After you have installed the project locally using the instructions above,
you should have logged into your Google Cloud account.

If you are the admin of an empty Google Cloud project, you can run

```bash
ops/infrastructure/setup.sh
```

The above command enables the necessary APIs in the cloud project
and sets up triggers to your repo, so that deploys happen via Git commits.

Creating and merging PRs for the production and staging banches
will cause deployment manager to read the specs found in the "ops" folder
and roll out the changes.

</details>
