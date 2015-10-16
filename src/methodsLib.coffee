fs = require 'fs'
{exec} = require 'child_process'
CWD = process.cwd()
methods =

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

  generateNodeBundle: (dirName, settingsFile)->
    self = @
    console.log("BUILDING NODEJS BUNDLE TO #{dirName} ...")
    exec "cd #{CWD} && meteor build --directory #{dirName}", (err, stderr, stdout)->
      console.log err if err
      console.log stderr + stdout
      console.log("COPYING #{settingsFile} ...")
      exec "cd #{CWD} && cp #{settingsFile} #{dirName}" , (err, stderr, stdout)->
        console.log err if err
        console.log stderr + stdout

        self.goodBye settingsFile, dirName

  checkIfMeteorApp: ()->
    console.log("CHECKING IF CWD IS METEOR APP")
    result = false
    try
      stats = fs.lstatSync CWD + '/.meteor'
      if stats.isDirectory()
        result = true
    catch error
      result = false
      throw new Error("THIS IS NOT A METEOR APP!")
    finally
      return result

  goodBye: (fileName, bundleDir)->
    if fileName
      if bundleDir
        console.log "GENERATED NODE BUNDLE #{bundleDir} AND #{fileName}"
        console.log "PLEASE INSTALL DEPS BY YOURSELF `cd #{bundleDir}/bundle/programs/server && npm i`"
        console.log "RUN APP WITH IN #{bundleDir} WITH `pm2 start #{fileName}`"
      else
        console.log("GENERATED #{fileName}")
        console.log("now generate a node bundle `meteor build --directory .build && cp #{fileName} .build/`")
        console.log("then install deps `cd .build/bundle/programs/server && npm i`")
        console.log("finally go to .build and start app with `pm2 start #{fileName}`")
      console.log "BYE"


module.exports = methods
