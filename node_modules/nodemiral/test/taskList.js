var TaskList = require('../lib/taskList');
var Session = require('../lib/session');
var assert = require('assert');

suite('TaskList', function() {
  
test('register and run', function(done) {
    var optionsList = [];
    var session = new Session('host');
    TaskList.registerTask('simpleTask', function(_session, options, callback) {
      assert.equal(session, _session);
      optionsList.push(options);
      callback();
    });

    var taskList = new TaskList('simple', {pretty: false});
    taskList.simpleTask('Simple Name', {aa: 10});
    taskList.simpleTask('Simple Name2', {aa: 20});
    taskList.run(session, function(summaryMap) {
      assert.deepEqual(summaryMap[session._host], {error: null, history: [
        {task: 'Simple Name', status: 'SUCCESS'},
        {task: 'Simple Name2', status: 'SUCCESS'}
      ]});
      assert.deepEqual(optionsList, [{aa: 10}, {aa: 20}]);
      done();
    });
  });
  test('when error', function(done) {
    var session = new Session('host');
    TaskList.registerTask('simpleTask2', function(_session, options, callback) {
      assert.equal(session, _session);
      if(options.aa == 20) {
        callback(new Error('error-here'));
      } else {
        callback();
      }
    });

    var taskList = new TaskList('simple', {pretty: false});
    taskList.simpleTask2('one', {aa: 10});
    taskList.simpleTask2('two', {aa: 20});
    taskList.simpleTask2('three', {aa: 30});
    taskList.run(session, function(summaryMap) {
      var summary = summaryMap[session._host];
      assert.equal(summary.error.message, 'error-here');
      assert.deepEqual(summary.history, [
        {task: 'one', status: 'SUCCESS'},
        {task: 'two', status: 'FAILED', error: 'error-here'}
      ]);
      done();
    });
  });

  test('when error - with ignoreErrors', function(done) {
    var session = new Session('host');
    TaskList.registerTask('simpleTask3', function(_session, options, callback) {
      assert.equal(session, _session);
      if(options.aa == 20) {
        callback(new Error('error-here'));
      } else {
        callback();
      }
    });

    var taskList = new TaskList('simple', {pretty: false, ignoreErrors: true});
    taskList.simpleTask3('one', {aa: 10});
    taskList.simpleTask3('two', {aa: 20});
    taskList.simpleTask3('three', {aa: 30});
    taskList.run(session, function(summaryMap) {
      var summary = summaryMap[session._host];
      assert.ifError(summary.error);
      assert.deepEqual(summary.history, [
        {task: 'one', status: 'SUCCESS'},
        {task: 'two', status: 'FAILED', error: 'error-here'},
        {task: 'three', status: 'SUCCESS'}
      ]);
      done();
    });
  });

  test('concat', function(done) {
    var optionsList = [];
    var session = new Session('host');
    TaskList.registerTask('simpleTask', function(_session, options, callback) {
      assert.equal(session, _session);
      optionsList.push(options);
      callback();
    });

    var tl1 = new TaskList('one', {pretty: false});
    tl1.simpleTask('Simple Name', {aa: 10});
    tl1.simpleTask('Simple Name2', {aa: 20});

    var tl2 = new TaskList('two', {pretty: false});
    tl2.simpleTask('Simple Name', {aa: 30});
    tl2.simpleTask('Simple Name2', {aa: 40});

    var tl3 = new TaskList('three', {pretty: false});
    tl3.simpleTask('Simple Name', {aa: 50});
    tl3.simpleTask('Simple Name2', {aa: 60});

    var combined = tl1.concat([tl2, tl3]);
    assert.equal(combined._name, tl1._name + '+');

    combined.run(session, function(summaryMap) {
      assert.ifError(summaryMap[session._host].error);
      assert.deepEqual(optionsList, [
        {aa: 10}, {aa: 20}, {aa: 30}, {aa: 40}, {aa: 50}, {aa: 60}
        ]);
      done();
    });
  });

  test('variable mapper', function(done) {
    var optionsList = [];
    var session = new Session('host');
    TaskList.registerTask('first', function(_session, options, callback, varsMapper) {
      optionsList.push(options);
      var stdout = "value1";
      var stderr = "value2";
      varsMapper(stdout, stderr);
      callback();
    });

    TaskList.registerTask('second', function(_session, options, callback, varsMapper) {
      optionsList.push(options);
      //this does not support varsMappers, so simply do nothing
      callback();
    });

    var taskList = new TaskList('simple', {pretty: false});

    taskList.first('One', {aa: 10}, function(stdout, stderr) {
      this.simple = {
        v1: stdout,
        v2: stderr
      };
    });

    taskList.second('Two', {
      data: function() {return this.simple },
      aa: 20
    });

    taskList.run(session, function(summaryMap) {
      assert.deepEqual(summaryMap[session._host], {error: null, history: [
        {task: 'One', status: 'SUCCESS'},
        {task: 'Two', status: 'SUCCESS'}
      ]});

      assert.deepEqual(optionsList, [{aa: 10}, {
        data: {
          v1: 'value1',
          v2: 'value2'
        },
        aa: 20
      }]);

      done();
    });
  });

  test('variable mapper: two sessions', function(done) {
    var optionsList = [];
    var sessions = [new Session('a'), new Session('b')];
    TaskList.registerTask('first', function(_session, options, callback, varsMapper) {
      optionsList.push(options);
      var stdout = "value1:" + _session._host;
      var stderr = "value2:" + _session._host;
      varsMapper(stdout, stderr);
      callback();
    });

    TaskList.registerTask('second', function(_session, options, callback, varsMapper) {
      optionsList.push(options);
      //this does not support varsMappers, so simply do nothing
      callback();
    });

    var taskList = new TaskList('simple', {pretty: false});

    taskList.first('One', {aa: 10}, function(stdout, stderr) {
      this.simple = {
        v1: stdout,
        v2: stderr
      };
    });

    taskList.second('Two', {
      data: function() {return this.simple },
      aa: 20
    });

    taskList.run(sessions, function(summaryMap) {
      assert.deepEqual(summaryMap['a'], {error: null, history: [
        {task: 'One', status: 'SUCCESS'},
        {task: 'Two', status: 'SUCCESS'}
      ]});

      assert.deepEqual(summaryMap['b'], {error: null, history: [
        {task: 'One', status: 'SUCCESS'},
        {task: 'Two', status: 'SUCCESS'}
      ]});

      var mappedValues = {};
      mappedValues.a = {simple: {v1: 'value1:a', v2: 'value2:a'}};
      mappedValues.b = {simple: {v1: 'value1:b', v2: 'value2:b'}};

      assert.deepEqual(taskList._vars, mappedValues);
      done();
    });
  });

  test('variable mapper: globalVars', function(done) {
    var optionsList = [];
    var sessions = [new Session('a'), new Session('b')];
    TaskList.registerTask('first', function(_session, options, callback, varsMapper) {
      optionsList.push(options);
      var stdout = "value1:" + _session._host;
      var stderr = "value2:" + _session._host;
      varsMapper(stdout, stderr);
      callback();
    });

    TaskList.registerTask('second', function(_session, options, callback, varsMapper) {
      optionsList.push(options);
      //this does not support varsMappers, so simply do nothing
      callback();
    });

    var taskList = new TaskList('simple', {pretty: false});

    taskList.first('One', {aa: 10}, function(stdout, stderr, globalVars) {
      this.simple = {
        v1: stdout,
        v2: stderr
      };

      globalVars.aa = stdout;
    });

    taskList.second('Two', {
      data: function() {return this.simple },
      aa: 20
    });

    taskList.run(sessions, function(summaryMap) {
      assert.deepEqual(summaryMap['a'], {error: null, history: [
        {task: 'One', status: 'SUCCESS'},
        {task: 'Two', status: 'SUCCESS'}
      ]});

      assert.deepEqual(summaryMap['b'], {error: null, history: [
        {task: 'One', status: 'SUCCESS'},
        {task: 'Two', status: 'SUCCESS'}
      ]});

      var mappedValues = {};
      mappedValues.a = {simple: {v1: 'value1:a', v2: 'value2:a'}};
      mappedValues.b = {simple: {v1: 'value1:b', v2: 'value2:b'}};

      assert.deepEqual(taskList._vars, mappedValues);
      assert.deepEqual(taskList._globalVars, {aa: 'value1:b'});
      done();
    });
  });

  test('variable mapper: string based variable replacements', function(done) {
    var optionsList = [];
    var session = new Session('host');
    TaskList.registerTask('first', function(_session, options, callback, varsMapper) {
      optionsList.push(options);
      var stdout = "value1";
      var stderr = "value2";
      varsMapper(stdout, stderr);
      callback();
    });

    TaskList.registerTask('second', function(_session, options, callback, varsMapper) {
      optionsList.push(options);
      //this does not support varsMappers, so simply do nothing
      callback();
    });

    var taskList = new TaskList('simple', {pretty: false});

    taskList.first('One', {aa: 10}, function(stdout, stderr) {
      this.simple = {
        v1: stdout,
        v2: stderr
      };
    });

    taskList.second('Two', {
      data: "v1: <%= simple.v1 %> - v2: <%= simple.v2 %>",
      aa: 20
    });

    taskList.run(session, function(summaryMap) {
      assert.deepEqual(summaryMap[session._host], {error: null, history: [
        {task: 'One', status: 'SUCCESS'},
        {task: 'Two', status: 'SUCCESS'}
      ]});

      assert.deepEqual(optionsList, [{aa: 10}, {
        data: "v1: value1 - v2: value2",
        aa: 20
      }]);

      done();
    });
  });

  test('run in parallel', function(done) {
    var optionsList = [];
    var sessions = [
      new Session("h1"),
      new Session("h2"),
    ];

    var execOrder = [];

    TaskList.registerTask('t1', function(_session, options, callback) {
      execOrder.push("t1::" + _session._host);
      setTimeout(callback, 100);
    });

    TaskList.registerTask('t2', function(_session, options, callback) {
      execOrder.push("t2::" + _session._host);
      setTimeout(callback, 100);
    });

    var taskList = new TaskList('simple', {pretty: false});
    taskList.t1('Simple Name');
    taskList.t2('Simple Name');
    
    taskList.run(sessions, function(summaryMap) {
      assert.deepEqual(execOrder, ["t1::h1", "t1::h2", "t2::h1", "t2::h2"]);
      done();
    });
  });

  test('run in series', function(done) {
    var optionsList = [];
    var sessions = [
      new Session("h1"),
      new Session("h2"),
    ];

    var execOrder = [];

    TaskList.registerTask('t1', function(_session, options, callback) {
      execOrder.push("t1::" + _session._host);
      setTimeout(callback, 100);
    });

    TaskList.registerTask('t2', function(_session, options, callback) {
      execOrder.push("t2::" + _session._host);
      setTimeout(callback, 100);
    });

    var taskList = new TaskList('simple', {pretty: false});
    taskList.t1('Simple Name');
    taskList.t2('Simple Name');
    
    taskList.run(sessions, {series: true}, function(summaryMap) {
      assert.deepEqual(execOrder, ["t1::h1", "t2::h1", "t1::h2", "t2::h2"]);
      done();
    });
  });
});