CliCommand  = require './cli-command'
gitUtil     = require './git-util'
util        = require './util'
execute     = require('./runner').execute

exports.listRemotes = (options, callback) ->
  [options, callback] = util.setOptions options, callback
  command = new CliCommand(['git', 'remote', 'show'], options)
  execOptions = processResult: (err, stdout) -> stdout.trim().split "\n"
  execute command, @_getOptions(execOptions), callback

exports.showRemote = (name, options, callback) ->
  [options, callback] = util.setOptions options, callback
  command = new CliCommand(['git', 'remote', 'show'], name, options)
  execOptions = processResult: (err, stdout) -> gitUtil.parseRemote stdout
  execute command, @_getOptions(execOptions), callback

exports.addRemote = (name, url, options, callback) ->
  [options, callback] = util.setOptions options, callback
  command = new CliCommand(['git', 'remote', 'add'], [name, url], options)
  execute command, @_getOptions(), callback

exports.setRemoteUrl = (name, url, options, callback) ->
  [options, callback] = util.setOptions options, callback
  command = new CliCommand(['git', 'remote', 'set-url'], [name, url], options)
  execute command, @_getOptions(), callback
