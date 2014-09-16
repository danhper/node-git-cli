util       = require './util'
_          = require 'underscore'
CliCommand = require './cli-command'
execute    = require('./runner').execute

exports.add = (files, options, callback) ->
  if _.isArray files
    [options, callback] = util.setOptions options, callback
  else
    [options, callback] = util.setOptions files, options
    files = ['.']
  args = []
  Array.prototype.push.apply(args, files)
  command = new CliCommand(['git', 'add'], args, options)
  execute command, @_getOptions(), callback

exports.commit = (message, options, callback) ->
  [options, callback] = util.setOptions options, callback
  cliOpts = _.extend({m: message}, options)
  command = new CliCommand(['git', 'commit'], cliOpts)
  execute command, @_getOptions(), callback

exports.checkout = (branch, options, callback) ->
  [options, callback] = util.setOptions options, callback
  command = new CliCommand(['git', 'checkout'], branch, options)
  execute command, @_getOptions(), callback

exports.merge = (args, options, callback) ->
  [options, callback] = util.setOptions options, callback
  command = new CliCommand(['git', 'merge'], args, options)
  execute command, @_getOptions(), callback
