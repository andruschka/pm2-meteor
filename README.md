# pm2-meteor
A command line tool, that will generate a pm2-env.json for running your Meteor app under PM2.  
This is just a beta, more functions - like deployment support - coming soon.

## Installation
```
$ npm i -g pm2-meteor
```

## Usage
```
$ cd myMeteorProject
$ pm2-meteor --settings path/to/meteorSettings.json
```
1. Provide the cli with the needed infos (MONGO URL etc).
2. pm2-meteor will generate a pm2-env.json file into your meteor app root.
3. Now generate a node bundle and copy pm2-env.json to it, then deploy it to your server. (Dont forget to install the deps!)
4. Run your app with pm2 start pm2-env.json. THATS IT!

```
$ pm2 start pm2-env.json
```

## Help
```
$ pm2-meteor --help
```
