# pm2-meteor
A CLI tool, that will deploy your Meteor app (from your dev machine or from git) as nodejs-bundle and run it with pm2.  
(tested with Ubuntu and Freebsd hosts)
## Heads up!
This tool is still under construction!
We decided to build this, because meteor-up didn't fit our requirements.  
That said, meteor-up is an awesome tool!
(We are running apps on ubuntu and freebsd, and want to run them with pm2)

## Installation
```
$ npm i -g pm2-meteor
```

## Usage
### 1. Init a pm2-meteor.json config file into an empty dir
```
$ mkdir ninjaApp_deployment
$ cd ninjaApp_deployment
$ pm2-meteor init
```

### 2. Complete the generated pm2-meteor.json file
```
{
  // the name of your app
  "appName": "ninjaApp",

  // where your app is located
  "appLocation": {
    "local": "~/Workspace/ninjaApp"
  // or you can also deploy with git ;-)
  // (use username:password@github.com/... for authentication)
  //   "git": "https://user:password@github.com/andruschka/ninjaApp",
  //   "branch": "production"
  },

  // where the meteor settings are located
  "meteorSettingsLocation":"~/Workspace/ninjaApp/settings/production.json",
  // or RELATIVE to app root, if you are deploying with git
  // "meteorSettingsLocation":"settings/production.json",

  // build flags for Meteor
  "meteorBuildFlags": "--architecture os.linux.x86_64"

  // runs as command in the meteor app before building
  "prebuildScript": "",
  // say you are still using meteorite and want to install deps before deploying:
  // "prebuildScript": "mrt install",

  // the env vars
  // (METEOR_SETTINGS will be generated from your meteor-settings file)
  "env": {
    "ROOT_URL": "http://ninja.my-host.com",
    "PORT": 4004,
    "MONGO_URL": "mongodb://localhost:27017/ninjaApp"
  },

  // infos for deployment
  "server": {
    "host": "my-host.com",
    "username": "nodejs",
    "password": "trustno1",
    // or auth with pem file
    // "pem":"~/.ssh/id_rsa",

    // this dir will contain your apps
    // (app will be deployed to /opt/pm2-meteor/ninjaApp)
    "deploymentDir": "/opt/pm2-meteor",

    // exec mode for pm2
    "exec_mode": "cluster_mode",
    "instances": 2
  }
}
```

### 3. Deploy your app
```
$ pm2-meteor deploy
```
If you already have deployed this app before, the old app tar-bundle will be moved to a ./backup directory.  
If something goes wrong - ssh to your host and:
```
$ cd /opt/pm2-meteor/ninjaApp/backup
$ tar -xf bundle.tar.gz -C ../
$ cd ../ && pm2 startOrRestart pm2-env.json
```

### 4. Control your app
```
$ pm2-meteor start
$ pm2-meteor stop
$ pm2-meteor status
```

## If you want to deploy yourself and just need a bundle
```
$ pm2-meteor generateBundle
```
