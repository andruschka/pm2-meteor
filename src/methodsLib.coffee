fs = require 'fs'
{exec} = require 'child_process'
nodemiral = require 'nodemiral'
path = require 'path'
prompt = require 'prompt'
cli = require 'cli'
CWD = -> process.cwd()
defaultAppname = path.basename CWD()

methods =
  configWizzard: (opts, cb)->
  	prompt.message = "pm2-meteor"
  	prompt.start()
  	promptQuestions = []
  	unless opts.appname
  		promptQuestions.push
  			name: "appname"
  			type: "string"
  			description: "Name of your App"
  			default: defaultAppname
  	unless opts.settings
  		promptQuestions.push
  			name: "settings"
  			type: "string"
  			description: "Meteor settings file"
  	unless opts.url
  		promptQuestions.push
  			name: "url"
  			type: "string"
  			description: "ROOT URL your app will run on"
  			required: true
  			message: "You must enter a Root URL"
  	unless opts.port
  		promptQuestions.push
  			name: "port"
  			type: "number"
  			description: "Port your app should run on"
  			default: 3000
  	unless opts.mongo
  		promptQuestions.push
  			name: "mongo"
  			type: "string"
  			description: "MongoDB URL"
  			required: true
  			message: "You must enter a MongoDB URL"
  	unless opts.instances
  		promptQuestions.push
  			name: "instances"
  			type: "number"
  			description: "How much instances to run?"
  			default: 1
  	prompt.get promptQuestions, (err, res)->
      if err
        cb err, null
      else
        cbRes = opts
        for key, value of res
          cbRes[key] = value
        cb null, cbRes

  generatePM2Settings: (opts, generateBundle)->
    pm2Json =
      apps: []
    appTemplate =
      name: null
      script: "./bundle/main.js"
      exec_mode: "fork_mode"
      env:
        "PORT": null
        "MONGO_URL": null
        "ROOT_URL": null
        "METEOR_SETTINGS": {}
    pm2Filename = "pm2-env.json"
    appTemplate.name = opts.appname
    appTemplate.env["PORT"] = opts.port
    appTemplate.env["MONGO_URL"] = opts.mongo
    appTemplate.env["ROOT_URL"] = opts.url
    if opts.instances > 1
      appTemplate.exec_mode = "cluster_mode"
      appTemplate.instances = opts.instances
    if opts.settings and opts.settings.trim() isnt ""
      settingsObj = JSON.parse(fs.readFileSync("#{opts.settings}", 'utf8'))
      if settingsObj?
        appTemplate.env["METEOR_SETTINGS"] = settingsObj

    pm2Json.apps.push appTemplate

    fs.writeFileSync(pm2Filename, JSON.stringify(pm2Json, null, 2))

    if generateBundle
      @generateNodeBundle generateBundle, pm2Filename
    else
      @goodBye pm2Filename

  generateNodeBundle: (dirName, settingsFile, cb)->
    cli.info "Building Node Bundle"
    exec "cd #{CWD()} && meteor build --directory #{dirName}", (err, stderr, stdout)->
      cli.fatal err if err
      console.log stderr + stdout
      cli.info "Copying #{settingsFile} into Node Bundle"
      exec "cd #{CWD()} && cp #{settingsFile} #{dirName}" , (err, stderr, stdout)->
        cli.fatal err if err
        console.log stderr + stdout
        cli.ok "Done building Node Bundle under #{dirName}"
        cb() if cb

  shippNodeBundle: (bundleDir, settingsFile)->
    @generateNodeBundle bundleDir, settingsFile, ()->
      exec "scp -rp #{bundleDir} root@betawerk.co:/opt/pm2-meteor/#{bundleDir}", (err, stderr, stdout)->
        cli.fatal err
        console.log stderr + stdout
        cli.ok "Deployed your App real quick!"


  checkIfMeteorApp: ()->
    cli.info "Checking if Meteor App"
    result = false
    try
      stats = fs.lstatSync CWD() + '/.meteor'
      if stats.isDirectory()
        result = true
    catch error
      result = false
      cli.fatal "This is not a Meteor Application"
    finally
      return result

  goodBye: (generatedConfig, deployedBundle)->
    if deployed
      cli.ok "Shipped your Application to /opt/pm2-meteor/#{deployedBundle}!"
    if generatedConfig
      cli.ok "Generated #{generatedConfig}"

module.exports = methods
