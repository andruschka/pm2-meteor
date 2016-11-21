var EventEmitter = require('events').EventEmitter;
var util = require('util');
var Session = require('./session');
var ejs = require('ejs');
var colors = require('colors');
var async = require('async');


function TaskList(name, options) {
  if(!(this instanceof TaskList)) {
    return new TaskList(name, options);
  }
  this._name = name;
  this._options = options || {};

  this._pretty = this._options.pretty !== false;
  this._ignoreErrors = this._options.ignoreErrors;
  this._taskQueue = [];

  //used as a global variable used by all the tasks for each session
  this._vars = {};

  //used by all the tasks and sessions;
  this._globalVars = {};
}

util.inherits(TaskList, EventEmitter);

TaskList.prototype.run = function(sessions, options, callback) {
  var self = this;
  
  if(!sessions) {
    throw new Error('First parameter should be either a session or a list of sessions');
  } else if(!(sessions instanceof Array)) {
    sessions = [sessions];
  }

  if(typeof(options) == 'function') {
    callback = options;
    options = {};
  }
  options = options || {};
  var summaryMap = {};
  var completed = 0;

  self.log('info', '\nStarted TaskList: ' + this._name);

  if(options.series) {
    async.mapSeries(sessions, iterator, completedCallback);
  } else {
    async.map(sessions, iterator, completedCallback);
  }

  function iterator(session, cb) {
    self._runTaskQueue(session, function(err, history) {
      summaryMap[session._host] = {error: err, history: history};
      cb(err);
    });
  }

  function completedCallback() {
    if(callback) callback(summaryMap);
  }
};

TaskList.prototype.concat = function(taskLists, name, options) {
  if(typeof(name) == 'object') {
    options = name;
    name = null;
  }

  name = name || this._name + '+';
  options = options || this._options;
  var newTaskList = new TaskList(name, options);

  //merge content of _taskQueue of all taskLists into the new one
  var actionQueueList = taskLists.map(function(taskList) { return taskList._taskQueue; });
  actionQueueList.unshift(this._taskQueue);
  newTaskList._taskQueue = newTaskList._taskQueue.concat.apply(newTaskList._taskQueue, actionQueueList);

  return newTaskList;
};

TaskList.prototype._runTaskQueue = function(session, callback) {
  var self = this;
  var cnt = 0;
  var taskHistory = [];
  
  runTask();

  function runTask() {
    var task = self._taskQueue[cnt++];
    if(task) {
      self.emit('started', task.id);
      self.log('log', util.format('[%s] '.magenta+'- %s', session._host, task.id));

      var options = self._evaluateOptions(task.options, session);
      TaskList._registeredTasks[task.type](session, options, function(err) {
        if(err) {
          taskHistory.push({
            task: task.id,
            status: 'FAILED',
            error: err.message
          });
          self.emit('failed', err, task.id);
          self.log('error', util.format('[%s] '.magenta+'x %s: FAILED\n\t%s'.red, session._host, task.id, err.message.replace(/\n/g, '\n\t')));

          if(self._ignoreErrors) {
            runTask();
          } else {
            callback(err, taskHistory);
          }
        } else {
          taskHistory.push({
            task: task.id,
            status: 'SUCCESS'
          });
          self.log('log', util.format('[%s] '.magenta+'- %s: SUCCESS'.green, session._host, task.id));
          self.emit('success', task.id);
          runTask();
        }
      }, function(stdout, stderr) {
        var vars = self._getVarsForSession(session);
        if(task.varsMapper) {
          task.varsMapper.call(vars, stdout, stderr, self._globalVars);
        }
      });
    } else {
      callback(null, taskHistory);
    }
  }
};

TaskList.prototype._getVarsForSession = function(session) {
  if(!this._vars[session._host]) {
    this._vars[session._host] = {};
  }

  return this._vars[session._host];
};

TaskList.prototype._evaluateOptions = function(options, session) {
  var self = this;

  if(options instanceof Array) {
    var data = [];
    for(var lc=0; lc<options.length; lc++) {
      data.push(self._evaluateOptions(options[lc], session));
    }
    return data;
  } else if(typeof(options) == 'object') {
    var data = {};
    for(var key in options) {
      var value = options[key];

      if(typeof(value) == 'function') {
        var vars = self._getVarsForSession(session);
        data[key] = value.call(vars, self._globalVars);
      } else if(value == null) {
        data[key] = value;
      } else if(typeof(value) == 'string') {
        //add ejs support
        var vars = self._getVarsForSession(session);
        data[key] = ejs.compile(value)(vars);
      } else {
        data[key] = self._evaluateOptions(value, session);
      }
    }
    return data;
  } else {
    return options;
  }
};

TaskList.prototype.log = function(type, message) {
  if(this._pretty) {
    if(type == 'info') {
      message = message.bold.blue;
    } else if(type == 'error') {
      message = message.bold.red;
    } else {
      message = message.cyan;
    }

    console[type](message);
  }
};

TaskList._registeredTasks = {};

TaskList.registerTask = function(name, callback) {
  TaskList._registeredTasks[name] = callback;
  TaskList.prototype[name] = function(id, options, varsMapper) {
    this._taskQueue.push({
      type: name, 
      id: id,
      options: options,
      varsMapper: varsMapper
    });
  };
};

module.exports = TaskList;
