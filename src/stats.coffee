_          = require 'underscore'
gitUtil    = require './git-util'
execute    = require('./runner').execute
util       = require './util'
CliCommand = require './cli-command'

exports.diff = (options={}, callback) ->
  [options, callback] = util.setOptions options, callback
  args = @_getDiffArgs(options)
  command = new CliCommand(['git', 'diff'], args, options)
  execute command, @_getOptions(), callback

exports.diffStats = (options={}, callback) ->
  [options, callback] = util.setOptions options, callback
  args = @_getDiffArgs(options)
  cliOpts = _.extend({ shortstat: '' }, options)
  command = new CliCommand(['git', 'diff'], args, cliOpts)
  execOptions = processResult: (err, stdout) -> gitUtil.parseShortDiff(stdout)
  execute command, @_getOptions(execOptions), callback

exports._getDiffArgs = (options) ->
  args = []
  args.push options.source if options.source?
  args.push options.target if options.target?
  if options.path?
    args.push '--'
    Array.prototype.push.apply args, options.paths
  args

exports.status = (options, callback) ->
  [options, callback] = util.setOptions options, callback
  command = new CliCommand(['git', 'status'], _.extend({ s: '' }, options))
  execOptions =
    processResult: (err, stdout) =>
      statusInfo = gitUtil.parseStatus(stdout)
      _.each(statusInfo, (f) => f.fullPath = "#{@workingDir()}/#{f.path}")
  execute command, @_getOptions(execOptions), callback

exports.log = (options={}, callback) ->
  [options, callback] = util.setOptions options, callback
  format = '{"author": "%an", "email": "%ae", "date": "%cd", "subject": "%s", "body": "%b", "hash": "%H"},'
  cliOpts = _.extend({ pretty: "format:#{format}" }, options)
  command = new CliCommand(['git', 'log'], cliOpts)
  execOptions = processResult: (err, stdout) -> gitUtil.parseLog(stdout)
  execute command, @_getOptions(execOptions), callback
