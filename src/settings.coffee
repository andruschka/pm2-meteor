module.exports =
  pm2MeteorConfigName: "pm2-meteor.json"
  pm2MeteorConfigTemplate:
    appName: ""
    appLocation:
      local: ""
      git: ""
      branch: "master"
    meteorSettingsLocation: ""
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
      exec_mode: "fork_mode"
      instances: 0
  pm2EnvConfigName: "pm2-env.json"
  pm2EnvConfigTemplate:
    apps: []
  localBuildDir: ".build"
  bundleTarName: "bundle.tar.gz"
  bundleName: "bundle"
  backupDir: "backup"
  gitDirName: "git-src"
