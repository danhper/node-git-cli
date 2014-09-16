_          = require 'underscore'
util       = require './util'
CliCommand = require './cli-command'
execute    = require('./runner').execute

exports.push = (args, options, callback) ->
  args = [args] if _.isString(args)
  if _.isArray(args)
    [options, callback] = util.setOptions(options, callback)
  else
    [[options, callback], args] = [util.setOptions(args, options), []]
  command = new CliCommand(['git', 'push'], args, options)
  execute command, @_getOptions(), callback
