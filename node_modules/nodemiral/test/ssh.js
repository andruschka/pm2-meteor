var SSH = require('../lib/ssh');
var SSH2 = require('ssh2');
var sinon = require('sinon');
var assert = require('assert');
var EventEmitter = require('events').EventEmitter;

suite('SSH', function() {
  suite('_onReady', function() {
    test('listen before ready', function(done) {
      var client = new SSH();
      client._onReady(done);
      client._client.emit('ready');
    });

    test('listen after ready', function(done) {
      var client = new SSH();
      client._client.emit('ready');
      client._onReady(done);
    });
  });

  suite('execute', function() {
    test('execute and error', function(done) {
      var client = new SSH();
      client._client.emit('ready');
      var command = "the-command";

      client._client.exec = sinon.stub();
      client._client.exec.callsArgWith(1, new Error());

      client.execute(command, function(err) {
        assert.ok(err);
        done();
      });
    });

    test('execute and stream', function(done) {
      var client = new SSH();
      client._client.emit('ready');
      var command = "the-command";

      client._client.exec = sinon.stub();
      var stream = new EventEmitter();
      stream.stderr = new EventEmitter();

      client._client.exec.callsArgWith(1, null, stream);

      var options = {
        onStdout: sinon.mock(),
        onStderr: sinon.mock()
      };

      client.execute(command, options, function(err, context) {
        assert.ifError(err);
        assert.deepEqual(context, {
          code: 0,
          signal: 'SIGINT',
          stderr: 'stderr',
          stdout: 'stdout'
        })

        assert.equal(options.onStdout.args[0][0], 'stdout');
        assert.equal(options.onStderr.args[0][0], 'stderr');
        done();
      });

      stream.emit('data', new Buffer('stdout'));
      stream.stderr.emit('data', new Buffer('stderr'));
      stream.emit('close', 0, 'SIGINT');
    });
  });

  suite('putFile', function() {
    test('error on the request', function(done) {
      var client = new SSH();
      client._client.emit('ready');

      client._client.sftp = sinon.stub();
      client._client.sftp.callsArgWith(0, new Error());

      client.putFile('src', 'dest', function(err) {
        assert.ok(err);
        done();
      });
    });

    test('error on the fastPut', function(done) {
      var client = new SSH();
      client._client.emit('ready');

      client._client.sftp = sinon.stub();
      var sftp = {
        fastPut: sinon.mock()
      };
      client._client.sftp.callsArgWith(0, null, sftp);
      sftp.fastPut.callsArgWith(3, new Error());

      client.putFile('src', 'dest', function(err) {
        assert.ok(err);
        done();
      });
    });

    test('success on the fastPut', function(done) {
      var client = new SSH();
      client._client.emit('ready');

      client._client.sftp = sinon.stub();
      var sftp = {
        fastPut: sinon.mock()
      };
      client._client.sftp.callsArgWith(0, null, sftp);
      sftp.fastPut.callsArgWith(3, null);

      client.putFile('src', 'dest', function(err) {
        assert.ifError(err);
        done();
      });
    });

    test('success on the fastPut with progress', function(done) {
      var client = new SSH();
      client._client.emit('ready');

      client._client.sftp = sinon.stub();
      var sftp = {
        fastPut: function(src, dest, _options, callback) {
          assert.equal(src, 'src');
          assert.equal(dest, 'dest');
          _options.step(0, 10, 20);
          _options.step(0, 10, 20);
          callback(null);
        }
      };

      client._client.sftp.callsArgWith(0, null, sftp);

      var options = {
        onProgress: sinon.stub()
      }
      client.putFile('src', 'dest', options, function(err) {
        assert.ifError(err);
        assert.equal(options.onProgress.callCount, 2);
        assert.deepEqual(options.onProgress.args, [
          [50], [100]
        ]);
        done();
      });
    });
  })

  suite('putContent', function() {
    test('error on sftp', function(done) {
      var client = new SSH();
      client._client.emit('ready');

      client._client.sftp = sinon.stub();
      var sftp = {};
      client._client.sftp.callsArgWith(0, new Error());

      client.putContent('some-commnads', 'dest', function(err) {
        assert.ok(err);
        done();
      });
    });

    test('error on open file', function(done) {
      var client = new SSH();
      client._client.emit('ready');

      client._client.sftp = sinon.stub();
      var sftp = {
        open: sinon.stub().callsArgWith(2, new Error())
      };
      client._client.sftp.callsArgWith(0, null, sftp);

      client.putContent('some-commnads', 'dest', function(err) {
        assert.ok(err);
        assert.equal(sftp.open.args[0][0], 'dest');
        done();
      });
    });

    test('error on writing data', function(done) {
      var client = new SSH();
      client._client.emit('ready');
      var fileHanlde = 74;

      client._client.sftp = sinon.stub();
      var sftp = {
        open: sinon.stub().callsArgWith(2, null, fileHanlde),
        write: sinon.stub().callsArgWith(5, new Error())
      };
      client._client.sftp.callsArgWith(0, null, sftp);

      client.putContent('some-commnads', 'dest', function(err) {
        assert.ok(err);
        assert.equal(sftp.open.args[0][0], 'dest');
        done();
      });
    });

    test('success on writing data', function(done) {
      var client = new SSH();
      client._client.emit('ready');
      var fileHanlde = 74;

      client._client.sftp = sinon.stub();
      var sftp = {
        open: sinon.stub().callsArgWith(2, null, fileHanlde),
        write: sinon.stub().callsArgWith(5, null),
        close: sinon.stub()
      };
      client._client.sftp.callsArgWith(0, null, sftp);
      sftp.close.callsArgWith(1, null);

      client.putContent('some-commnads', 'dest', function(err) {
        assert.ifError(err);
        assert.equal(sftp.open.args[0][0], 'dest');
        assert.ok(sftp.close.called);
        assert.equal(sftp.close.args[0][0], fileHanlde);
        done();
      });
    });
  });
});