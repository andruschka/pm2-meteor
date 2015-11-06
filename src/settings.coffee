module.exports =
  pm2MeteorConfigName: "pm2-meteor.json"
  pm2MeteorConfigTemplate:
    appName: ""
    appLocation:
      local: ""
      git: ""
      branch: "master"
    meteorSettingsLocation: ""
    prebuildScript: ""
    meteorBuildFlags: ""
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
      instances: 1
  pm2EnvConfigName: "pm2-env.json"
  pm2EnvConfigTemplate:
    apps: []
  localBuildDir: "/tmp/pm2-meteor-builds"
  bundleTarName: "bundle.tar.gz"
  bundleName: "bundle"
  backupDir: "backup"
  gitDirName: "git-src"
