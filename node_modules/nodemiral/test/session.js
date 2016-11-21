var Session = require('../lib/session');
var helpers = require('../lib/helpers');
var SSH = require('../lib/ssh');
var assert = require('assert');
var fs = require('fs');
var sinon = require('sinon');

suite('Session', function() {
  suite('_getSshConnInfo', function() {
    test('username and password', function() {
      var host = "the-host";
      var auth = {username: 'user', password: 'password'};
      var s = new Session(host, auth);
      var conf = s._getSshConnInfo();

      assert.deepEqual(conf, {
        host: host,
        username: auth.username,
        password: auth.password,
        readyTimeout: 60000
      });
    });

    test('username and pem', function() {
      var host = "the-host";
      var auth = {username: 'user', pem: 'the-pem'};
      var s = new Session(host, auth);
      var conf = s._getSshConnInfo();

      assert.deepEqual(conf, {
        host: host,
        username: auth.username,
        privateKey: auth.pem,
        readyTimeout: 60000
      });
    });

    test('custom options', function() {
      var host = "the-host";
      var auth = {username: 'user', pem: 'the-pem'};
      var options = {ssh: {port: 22}};
      var s = new Session(host, auth, options);
      var conf = s._getSshConnInfo();

      assert.deepEqual(conf, {
        host: host,
        port: options.ssh.port,
        username: auth.username,
        privateKey: auth.pem,
        readyTimeout: 60000
      });
    });
  });

  suite('_withSshClient', function() {
    var originalConnect = SSH.prototype.connect;
    setup(function() {
      SSH.prototype.connect = function() {};
    });

    teardown(function() {
      SSH.prototype.connect = originalConnect;
    });

    test('get a client', function(done) {
      var session = new Session('host', {username: 'u', password: 'p'});
      session._withSshClient(function(client, close) {
        client.close = done;
        close();
      });
    });

    test('get two client', function(done) {
      var session = new Session('host', {username: 'u', password: 'p'});
      session._withSshClient(function(client, close) {
        close();
        session._withSshClient(function(client2, close2) {
          client2.close = done;
          close2();
        });
      });
    });

    test('get a keepAlive client', function(done) {
      var options = {keepAlive: true};
      var session = new Session('host', {username: 'u', password: 'p'}, options);
      session._withSshClient(function(client, close) {
        client.close = function() {
          throw new Error("cannot get closed!");
        };
        close();
        client.close = done;
      });

      session.close();
    });
  });

  suite('.copy()', function() {
    test('binary file with success', function(done) {
      var session = new Session('host', {username: 'root', password: 'kuma'});
      var src = "src";
      var dest = "dest";
      var options = {aa: 20};

      var client = {
        putFile: function(_src, _dest, _options, callback) {
          assert.equal(_src, src);
          assert.equal(_dest, dest);
          assert.deepEqual(_options, {});
          callback(null);
        }
      };
      var close = sinon.stub();
      session._withSshClient = sinon.stub();
      session._withSshClient.callsArgWith(0, client, close);

      session.copy(src, dest, options, function(err, code, logs) {
        assert.ifError(err);
        assert.equal(code, 0);
        assert.ok(logs);
        assert.ok(close.called);
        done();
      });
    });

    test('binary file with success', function(done) {
      var session = new Session('host', {username: 'root', password: 'kuma'});
      var src = "src";
      var dest = "dest";
      var options = {aa: 20};

      var client = {
        putFile: function(_src, _dest, _options, callback) {
          callback(new Error());
        }
      };
      var close = sinon.stub();
      session._withSshClient = sinon.stub();
      session._withSshClient.callsArgWith(0, client, close);

      session.copy(src, dest, options, function(err) {
        assert.ok(err);
        assert.ok(close.called);
        done();
      });
    });

    test('binary file with progressBar', function(done) {
      var session = new Session('host', {username: 'root', password: 'kuma'});
      var src = "src";
      var dest = "dest";
      var options = {progressBar: true};

      var client = {
        putFile: function(_src, _dest, _options, callback) {
          assert.equal(_src, src);
          assert.equal(_dest, dest);
          _options.onProgress(100);
          callback(null);
        }
      };
      var close = sinon.stub();
      session._withSshClient = sinon.stub();
      session._withSshClient.callsArgWith(0, client, close);

      session.copy(src, dest, options, function(err, code, logs) {
        assert.ifError(err);
        assert.equal(code, 0);
        assert.ok(logs);
        assert.ok(close.called);
        done();
      });
    });

    test('vars with success', function(done) {
      var session = new Session('host', {username: 'root', password: 'kuma'});
      var src = "/tmp/" + Math.ceil(Math.random() * 999999999);
      var dest = "dest";
      var options = {vars: {name: 'arunoda'}};
      fs.writeFileSync(src, '<%= name %>');

      var client = {
        putContent: function(content, _dest, callback) {
          assert.equal(content, options.vars.name);
          assert.equal(_dest, dest);
          callback(null);
        }
      };
      var close = sinon.stub();
      session._withSshClient = sinon.stub();
      session._withSshClient.callsArgWith(0, client, close);

      session.copy(src, dest, options, function(err, code, logs) {
        assert.ifError(err);
        assert.equal(code, 0);
        assert.ok(logs);
        assert.ok(close.called);
        fs.unlinkSync(src);
        done();
      });
    });

    test('vars with failed', function(done) {
      var session = new Session('host', {username: 'root', password: 'kuma'});
      var src = "/tmp/" + Math.ceil(Math.random() * 999999999);
      var dest = "dest";
      var options = {vars: {name: 'arunoda'}};
      fs.writeFileSync(src, '<%= name %>');

      var client = {
        putContent: function(content, _dest, callback) {
          callback(new Error());
        }
      };
      var close = sinon.stub();
      session._withSshClient = sinon.stub();
      session._withSshClient.callsArgWith(0, client, close);

      session.copy(src, dest, options, function(err) {
        assert.ok(err);
        assert.ok(close.called);
        done();
        fs.unlinkSync(src);
      });
    });
  });

  suite('.execute()', function() {
    test('execute and error', function(done) {
      var session = new Session('host', {username: 'root', password: 'kuma'});
      session._withSshClient = sinon.stub();

      var shellCommand = "ssdsdsds";
      var options = {aa: 10};

      var client = {
        execute: function(_shellCommand, _options, callback) {
          assert.equal(_shellCommand, _shellCommand);
          assert.deepEqual(_options, options);
          callback(new Error());
        }
      };
      var close = sinon.stub();
      session._withSshClient.callsArgWith(0, client, close);
      session.execute(shellCommand, options, function(err) {
        assert.ok(err);
        assert.ok(close.called);
        done();
      });
    }); 

    test('execute and okay', function(done) {
      var session = new Session('host', {username: 'root', password: 'kuma'});
      session._withSshClient = sinon.stub();

      var shellCommand = "ssdsdsds";
      var options = {aa: 10};

      var client = {
        execute: function(_shellCommand, _options, callback) {
          assert.equal(_shellCommand, _shellCommand);
          assert.deepEqual(_options, options);
          callback(null, {
            code: 0,
            stdout: 'stdout',
            stderr: 'stderr'
          });
        }
      };
      var close = sinon.stub();
      session._withSshClient.callsArgWith(0, client, close);
      session.execute(shellCommand, options, function(err, code, logs) {
        assert.ifError(err);
        assert.ok(close.called);
        assert.ok(logs.stderr);
        assert.ok(logs.stdout);
        done();
      });
    }); 
  });

  suite('.executeScript', function() {
    test('file exists', function(done) {
      var session = new Session('host', {username: 'root', password: 'kuma'});
      session.execute = function(shellCommand, options, callback) {
        assert.equal(shellCommand, 'ls -all /');
        callback();
      };
      var file = '/tmp/' + Math.ceil(Math.random() * 9999999);
      fs.writeFileSync(file, 'ls -all /');
      session.executeScript(file, {}, function() {
        fs.unlinkSync(file);
        done();
      });
    });

    test('file not exists', function(done) {
      var session = new Session('host', {username: 'root', password: 'kuma'});
      session.execute = function(shellCommand, options, callback) {
        assert.equal(shellCommand, 'ls -all /');
        callback();
      };

      session.executeScript('/tmp/ssdcs', {}, function(err) {
        assert.ok(err);
        done();
      });
    });

    test('with ejs', function(done) {
      var session = new Session('host', {username: 'root', password: 'kuma'});
      session.execute = function(shellCommand, options, callback) {
        assert.equal(shellCommand, 'ls -all /');
        callback();
      };
      var file = '/tmp/' + Math.ceil(Math.random() * 9999999);
      fs.writeFileSync(file, 'ls <%= options %> /');
      session.executeScript(file, {vars: {options: '-all'}}, function() {
        fs.unlinkSync(file);
        done();
      });
    });

    test('with ejs options', function(done) {
      var session = new Session('host', {username: 'root', password: 'kuma'}, {ejs: {
        open: '{{',
        close: '}}'
      }});
      session.execute = function(shellCommand, options, callback) {
        assert.equal(shellCommand, 'ls -all /');
        callback();
      };
      var file = '/tmp/' + Math.ceil(Math.random() * 9999999);
      fs.writeFileSync(file, 'ls {{= options }} /');
      session.executeScript(file, {vars: {options: '-all'}}, function() {
        fs.unlinkSync(file);
        done();
      });
    });
  });
});