CliCommand  = require './cli-command'
gitUtil     = require './git-util'
util        = require './util'
execute     = require('./runner').execute

exports.listRemotes = (options, callback) ->
  [options, callback] = util.setOptions options, callback
  cb = util.wrapCallback callback, (err, stdout) -> stdout.trim().split "\n"
  command = new CliCommand(['git', 'remote', 'show'], options)
  execute command, @_getOptions(), cb

exports.showRemote = (name, options, callback) ->
  [options, callback] = util.setOptions options, callback
  cb = util.wrapCallback callback, (err, stdout) -> gitUtil.parseRemote stdout
  command = new CliCommand(['git', 'remote', 'show'], name, options)
  execute command, @_getOptions(), cb

exports.addRemote = (name, url, options, callback) ->
  [options, callback] = util.setOptions options, callback
  command = new CliCommand(['git', 'remote', 'add'], [name, url], options)
  execute command, @_getOptions(), callback

exports.setRemoteUrl = (name, url, options, callback) ->
  [options, callback] = util.setOptions options, callback
  command = new CliCommand(['git', 'remote', 'set-url'], [name, url], options)
  execute command, @_getOptions(), callback
