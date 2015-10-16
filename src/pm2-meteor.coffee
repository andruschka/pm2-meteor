
exec = require('child_process').exec
fs = require('fs')
readline = require('readline')
path = require 'path'
prompt = require 'prompt'
cli = require 'cli'
methods = require './methodsLib'
CWD = process.cwd()
defaultAppname = path.basename CWD

opts = cli.parse
	appname: [false, "Name of your app", 'string']
	settings: ['s', "Meteor settings file", 'path']
	url: ['u', "ROOT URL your app will run on", 'string']
	port: ['p', "Port your app should run on", 'number']
	mongo: ['m', "MongoDB URL", 'string']
	instances: ['i', "How much instances to run?", 'number']


methods.checkIfMeteorApp()

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
		type: "path"
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
# promptQuestions.push
# 	name: "generateNodeBundle"
# 	type: "string"
# 	description: "Should I generate a Node bundle? y/N"
# 	default: "N"
prompt.get promptQuestions, (err, res)->
	throw new Error err if err
	if res
		for key, value of res
			opts[key] = value

		methods.generatePM2Settings opts
