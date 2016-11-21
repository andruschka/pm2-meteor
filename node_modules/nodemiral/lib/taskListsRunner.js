var colors = require('colors');

function TaskListRunner(options) {
  if(!(this instanceof TaskListRunner)) {
    return new TaskListRunner(options);
  }

  this._options = options || {};
  this._items = [];

  this._vars = {};
  this._globalVars = {};
}

TaskListRunner.prototype.add = function(taskList, sessions, options) {
  var self = this;
  if(!sessions) {
    throw new Error('No session provided');
  } else if(!sessions instanceof Array) {
    sessions = [sessions]
  }

  options = options || {};
  if(typeof options.inheritVars === "undefined") {
    options.inheritVars = false;
  }

  if(options.inheritVars) {
    // share the same vars accross all the task lists
    taskList._vars = this._vars;
    taskList._globalVars = this._globalVars;
  }

  var taskListInfo = {
    taskList: taskList, 
    sessions: sessions,
    options: options
  };

  this._items.push(taskListInfo);
};

TaskListRunner.prototype.run = function() {
  var self = this;
  var count = 0;

  runTaskList();
  function runTaskList() {
    var item = self._items[count++];
    if(item) {
      item.taskList.run(item.sessions, item.options, function(summaryMap) {
        var erroredSummaryMap = self._pickErrored(summaryMap);
        if(erroredSummaryMap) {
          self._printErroredSummaryMap(erroredSummaryMap);
        } else {
          runTaskList();
        }
      });
    }
  }
};

TaskListRunner.prototype._pickErrored = function(summaryMap) {
  var erroredSummaryMap = {};
  var errorFound = false;

  for(var host in summaryMap) {
    if(summaryMap[host].error) {
      erroredSummaryMap[host] = summaryMap[host];
      errorFound = true;
    }
  }

  if(errorFound) {
    return erroredSummaryMap;
  } else {
    return null;
  }
};

TaskListRunner.prototype._printErroredSummaryMap = function(summaryMap) {
  var hosts = Object.keys(summaryMap);
  var message = "\u2718 ERROR(S) in: " + hosts.join(', ');
  console.error(message.bold.red);
};

module.exports = TaskListRunner;