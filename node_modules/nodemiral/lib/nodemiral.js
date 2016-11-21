var Session = require('./session');
var TaskList = require('./taskList');
var TaskListsRunner = require('./taskListsRunner');

var nodemiral = module.exports;
nodemiral.session = Session;
nodemiral.taskList = TaskList;
nodemiral.taskListsRunner = TaskListsRunner;
nodemiral.registerTask = TaskList.registerTask;

//load initial core tasks
require('./coreTasks')(nodemiral);