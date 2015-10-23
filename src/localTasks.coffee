fs = require 'fs'
{exec} = require 'child_process'
path = require 'path'
nodemiral = require 'nodemiral'
url = require 'url'
abs = require 'abs'
_settings = require './settings'
CWD = process.cwd()

isGitProject = (pm2mConf)->
  if !pm2mConf.appLocation.local or pm2mConf.appLocation.local.trim() is ""
    return true
  else
    return false


# Local tasks
module.exports =
  initPM2MeteorSettings: (done)->
    json = _settings.pm2MeteorConfigTemplate
    prettyJson = JSON.stringify(json, null, 2)
    try
      fs.writeFileSync _settings.pm2MeteorConfigName, prettyJson
    catch err
      done err
    done()

  generatePM2EnvironmentSettings: (pm2mConf, done)->
    envJson = _settings.pm2EnvConfigTemplate
    appJson = {}
    # Fill appJson
    appJson.name = pm2mConf.appName
    appJson.env = pm2mConf.env
    appJson.script = path.join(pm2mConf.server.deploymentDir, pm2mConf.appName, "bundle/main.js")
    appJson.exec_mode = pm2mConf.server.exec_mode
    appJson.instances = pm2mConf.server.instances
    # get Meteor settings
    meteorSettingsObj = {}
    unless isGitProject pm2mConf
      if pm2mConf.meteorSettingsLocation
        try
          meteorSettingsLocation = abs(pm2mConf.meteorSettingsLocation)
          meteorSettingsObj = JSON.parse(fs.readFileSync meteorSettingsLocation, 'utf8')
        catch err
          done err
    else
      done message: "Git deployment is still under construction"
    appJson.env["METEOR_SETTINGS"] = meteorSettingsObj
    envJson.apps.push appJson
    prettyJson = JSON.stringify(envJson, null, 2)
    try
      fs.writeFileSync _settings.pm2EnvConfigName, prettyJson
    catch err
      done message: "#{err.message}"
    done()

  bundleApplication: (pm2mConf, done)->
    exec "cd #{abs(pm2mConf.appLocation.local)} && meteor build #{pm2mConf.meteorBuildFlags} --directory #{CWD}", (err, stdout, stderr)->
      if err
        done err
      else
        exec "cd #{CWD} && tar -zcvf #{_settings.bundleTarName} #{_settings.bundleName} #{_settings.pm2EnvConfigName}", {maxBuffer: 1024*200000}, (err, stdout, stderr)->
          if err
            done err
          else
            done()

  makeClean: (done)->
    exec "cd #{CWD} && rm -rf bundle && rm #{_settings.pm2EnvConfigName} && rm bundle.tar.gz", (err, stdout, stderr)->
      if err
        done err
      else
        done()
