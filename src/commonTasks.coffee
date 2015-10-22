fs = require 'fs'
cli = require 'cli'
_settings = require './settings'
CWD = process.cwd()

module.exports =
  readPM2MeteorConfig: ()->
    conf = null
    try
      conf = JSON.parse(fs.readFileSync(_settings.pm2MeteorConfigName, 'utf8'))
    catch err
      cli.fatal "Error while trying to read pm2-meteor config: #{err.message}"
    if conf
      for checkProp in _settings.pm2MeteorConfigCheck
        if !conf[checkProp] or conf[checkProp] is ""
          cli.fatal "Please check your pm2-meteor config! #{checkProp}"
    return conf
