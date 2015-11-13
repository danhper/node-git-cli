_          = require 'underscore'
util       = require './util'
CliCommand = require './cli-command'
execute    = require('./runner').execute

getOptions = (args, options, callback) ->
  args = [args] if _.isString(args)
  if _.isArray(args)
    [options, callback] = util.setOptions(options, callback)
  else
    [[options, callback], args] = [util.setOptions(args, options), []]
  [args, options, callback]

makeAction = (action) ->
  (args, options, callback) ->
    [args, options, callback] = getOptions(args, options, callback)
    command = new CliCommand(['git', action], args, options)
    execute command, @_getOptions(), callback

for action in ['push', 'pull', 'fetch']
  exports[action] = makeAction(action)
