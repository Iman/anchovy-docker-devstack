# Deployment for anchovy.dev (Anchovy Projects)

This is the guide for deploying the development environment for anchovy projects using (Docker/Docker Composite, Rancher and Vault). The development stack includes Nginx, MongoDB, Radius, Memcache/Memcached, PHP5, MySQL, SSL, Composer, Wordpress and Symfony. 
## Prerequisites
- [vault](https://www.vaultproject.io/downloads.html)
- [jq](https://stedolan.github.io/jq/)

## Provision servers
Login to AWS console and provision one EC2s or DigitalOcean with at least 2GB memory, and it will be used as a rancher server and rancher agent.

## Install Rancher and configure the environment
SSH to the rancher ec2 instance or droplet and install docker using:

```# curl -s https://get.docker.com | bash```

Then install Rancher management platform using the following command:

```# docker run -d --restart=always -p 8080:8080 rancher/server```

Wait a few minutes and login to the WebUI for rancher platform:

http://ranceher-server-ip:8080/

and after that click on add hosts and choose **custom**, and then copy the registration command and paste it in the same host.

### Create development environment
To add new environments, you’ll need to navigate to the Manage Environments page. There are a couple of ways to get to the page.

- In the environment drop down, the Manage Environments link is at the bottom of the list of environments.
- In the account drop down, the Environments link is under the Settings section.
After navigating to the Environments page, you will see a list of environments.

Click on Add Environment. and then write **development** in the environment name.

### Enable Github access control

To secure your rancher environment you have to add access control for your Rancher, following the following instructions to enable access control for github:

In the Admin tab, click Access Control.

Currently, Rancher supports three methods of authentication: Active Directory, GitHub, Local and OpenLDAP. After authenticating your Rancher instance, Access Control will be considered enabled. With Access Control enabled, you will be able to manage different environments and share them with different groups of people.

When Access Control is enabled, the API is locked and requires either being authenticated as a user or by using an API key to access it.

#### GITHUB
Select the GitHub icon and follow the directions in the UI to register Rancher as a GitHub application. After clicking Authenticate with GitHub, Access Control is enabled and you are automatically logged into Rancher with your GitHub login credentials and as an admin of Rancher.

### Create API keys
Click on API to find the API endpoint. Whenever you create an API key, the endpoint URL provided will direct you to the specific environment that you are currently working in.

Within Rancher, all objects can be viewed in the API by selecting the View in API option in the object’s dropdown menu. The endpoint URL provided when creating the API key also gives all the links to the various portions of the API. Read more about how to use our API.

#### ADDING API KEYS

Before adding any API Keys, please confirm that you are in the correct environment. Each API Key is environment specific. Click on Add API Key. Rancher will generate and display your API Key for your environment. In Rancher, an API Key is a combination of a username (access key) and a password (secret key) - both are needed to authenticate when performing API calls.

Provide a Name for the API Key and click on Save.

#### Create env file
on your local computer create env file and write down the following in it:
```
export VAULT_ADDR="http://node-ip:8200"
export RANCHER_URL=http://rancher-ip:8080/
export RANCHER_ACCESS_KEY=xxxxxxx
export RANCHER_SECRET_KEY=xxxxxxx
```
source this env file using the following command:
```
source ./env
```

## Setup your docker images:

Clone the devops repo and and copy the devstack directory to the development ec2 node, after that ssh to the development ec2 node and cd to the devstack directory:

```
# cd repo_name/devstack
docker build -t anchovy/app app/
docker build -t anchovy/mysql mysql/
docker build -t anchovy/vault vault/
docker build -t anchovy/base base/
```
This will take sometime, and all images will be created, now run the docker-compose file, but don't forget to add the right repo url in GIT_REPO, GIT_NAME, GIT_MAIL, and GIT_BRANCH, download the rancher-compose file from your Rancher-platform, you will find it at the down right corner which called Download-cli

cd into the repo and run:
```
rancher-compose create
rancher-compose up
```
this will spin up your contianers.

## Initiating vault (one time only)
now we need to set up vault keys and passwords, note that this is a one time step and doesn't need to be repeated, first run the following command:

```
vault init -key-shares=1 -key-threshold=1
```
this will create one key and one root token, keep them in a safe place, and then run the following:

```
vault unseal key-generated-from-previous-step
vault auth token-generated-from-previous-step
```
now you have a functional vault server, to store your passwords and keys run the following:
```
cd repo/scripts
./init_vault.sh
```
feel free to change any of the passwords in that file but make sure that vault password matches the vault password in docker-compose.yml file

once you ran the init_vault script the containers will feel the change and will start to function.

Now the application should be up and running, using the ip of rancher server:
```
https://ip-of-rancher/
https://ip-of-rancher/blog
```
## Add CI/CD pipeline
To add your development pipeline create an account on Codeship and add the code github repo as a new project, then create your testing pipeline and add your tests (this should be a straight forward process), in deployment setting add a script and add the following script:
```
chmod u+x deployment.sh
./deployment.sh
```
you will find deployment.sh in the devops repo inside scripts directory, this script will restart the docker containers after you push a new code into the dev-master branch and only if the tests were OK.

put this script in the your code, and don't worry i already added a confgiuration line in nginx to prevent public access on this script.

one last step in codeship is to add environment variables, add the RANCHER_URL, RANCHER_ACCESS_KEY, and RANCHER_SECRET_KEY from the env file earlier.

Everything should be now ready for your development pipeline, have fun.

## My twitter account ##

If you want to keep up with updates, [follow me on twitter](http://twitter.com/imanpage).

## Bug tracking ##

This project uses [GitHub issues](https://github.com/Iman/anchovy-docker-devstack/issues).
If you have found bug, please create an issue.
