module.exports =
  pm2MeteorConfigName: "pm2-meteor.json"
  pm2MeteorConfigTemplate:
    appName: ""
    appLocation:
      gitUrl: ""
      branch: "master"
    meteorSettingsLocation: ""
    env:
      ROOT_URL: ""
      PORT: 3000
      MONGO_URL: ""
    server:
      host: ""
      username: ""
      password: ""
      deploymentDir: "/opt/pm2-meteor"
      exec_mode: "cluster_mode"
      instances: 0
  pm2MeteorConfigCheck: ['appName', 'appLocation', 'env', 'server']
  pm2EnvConfigName: "pm2-env.json"
  pm2EnvConfigTemplate:
    apps: []
  bundleTarName: "bundle.tar.gz"
  bundleName: "bundle"
  backupDir: "backupLocation"
