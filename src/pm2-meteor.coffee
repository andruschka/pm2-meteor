# fs = require('fs')
# {exec} = require('child_process')
# path = require 'path'
# CWD = process.cwd()
# defaultAppname = path.basename CWD
cli = require 'cli'
methods = require './methodsLib'

# Check if Meteor App
methods.checkIfMeteorApp()

# Parse options
opts = cli.parse
	appname: [false, "Name of your app", 'string']
	settings: ['s', "Meteor settings file", 'path']
	url: ['u', "ROOT URL your app will run on", 'string']
	port: ['p', "Port your app should run on", 'number']
	mongo: ['m', "MongoDB URL", 'string']
	instances: ['i', "How much instances to run?", 'number']

# Default task on init
defaultTask = ()->
	cli.ok "Building a pm2 config"
	methods.configWizzard opts, (err, res)->
		if err
			cli.fatal err
		else
			methods.generatePM2Settings res

# Check args
if cli.args and cli.args.length > 0
	switch cli.args[0]
		when "deploy"
			methods.shippNodeBundle('.pm2-bundle', 'pm2-env.json')
else
	defaultTask()
