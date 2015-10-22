fs = require 'fs'
{exec} = require 'child_process'
path = require 'path'
nodemiral = require 'nodemiral'
url = require 'url'
_settings = require './settings'
CWD = process.cwd()

# Local tasks
module.exports =
  initPM2MeteorSettings: (opts, done)->
    json = _settings.pm2MeteorConfigTemplate
    json.appName = opts.appName if opts.appName
    json.meteorSettingsLocation = path.resolve(CWD, opts.meteorSettingsLocation) if opts.meteorSettingsLocation
    json.env.ROOT_URL = opts.ROOT_URL if opts.ROOT_URL
    json.env.PORT = opts.PORT if opts.PORT
    json.env.MONGO_URL = opts.MONGO_URL if opts.MONGO_URL
    if opts.location
      parsedUrl = url.parse opts.location
      if parsedUrl.protocol
        json.appLocation.gitUrl = parsedUrl.href
        if opts.branch
          json.appLocation.branch = opts.branch
      else
        json.appLocation = path.resolve CWD, opts.location
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
    if pm2mConf.meteorSettingsLocation
      try
        meteorSettingsObj = JSON.parse(fs.readFileSync("#{pm2mConf.meteorSettingsLocation}", 'utf8'))
      catch err
        done "#{err.message}"
    appJson.env["METEOR_SETTINGS"] = meteorSettingsObj
    envJson.apps.push appJson
    prettyJson = JSON.stringify(envJson, null, 2)
    try
      fs.writeFileSync _settings.pm2EnvConfigName, prettyJson
    catch err
      done "#{err.message}"
    done()

  bundleApplication: (pm2mConf, done)->
    exec "cd #{pm2mConf.appLocation} && meteor build --directory #{CWD}", (err, stdout, stderr)->
      if err
        done err
      else
        exec "cd #{CWD} && tar -zcvf bundle.tar.gz bundle #{_settings.pm2EnvConfigName}", {maxBuffer: 1024*200000}, (err, stdout, stderr)->
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
