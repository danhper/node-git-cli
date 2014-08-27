fs     = require 'fs-extra'
S      = require 'string'
_      = require 'underscore'
path   = require 'path'

errors      = require './errors'
CliCommand  = require './cli-command'
CliOption   = require './cli-option'
execute     = require('./runner').execute
util        = require './util'
gitUtil     = require './git-util'

class Repository
  BAD_PATH_MSG = "repository path should point .git directory"

  constructor: (@path) ->
    unless S(@path).endsWith('.git')
      throw new errors.BadRepositoryError(BAD_PATH_MSG)

  @init: (path, options, callback) ->
    [options, callback] = util.setOptions options, callback
    fs.ensureDirSync path
    command = new CliCommand('git', ['init', path], options)
    cb = util.wrapCallback callback, (-> new Repository("#{path}/.git"))
    execute command, {}, cb

  @clone: (url, path, options, callback) ->
    [options, callback] = util.setOptions options, callback
    command = new CliCommand(['git', 'clone'], [url, path], options)
    cb = util.wrapCallback callback, (-> new Repository("#{path}/.git"))
    execute command, {}, cb

  add: (files, options, callback) ->
    if _.isArray files
      [options, callback] = util.setOptions options, callback
    else
      [options, callback] = util.setOptions files, options
      files = ['.']
    args = []
    Array.prototype.push.apply(args, files)
    command = new CliCommand(['git', 'add'], args, options)
    execute command, @_getOptions(), callback

  status: (options, callback) ->
    [options, callback] = util.setOptions options, callback
    command = new CliCommand(['git', 'status'], _.extend({ s: '' }, options))
    cb = util.wrapCallback callback, (err, stdout) =>
      statusInfo = gitUtil.parseStatus(stdout)
      _.each(statusInfo, (f) => f.fullPath = "#{@workingDir()}/#{f.path}")
    execute command, @_getOptions(), cb

  diff: (options, callback) ->
    [options, callback] = util.setOptions options, callback
    args = @_getDiffArgs(options)
    command = new CliCommand(['git', 'diff'], args, options)
    execute command, @_getOptions(), callback

  diffStats: (options, callback) ->
    [options, callback] = util.setOptions options, callback
    args = @_getDiffArgs(options)
    cliOpts = _.extend({ shortstat: '' }, options)
    command = new CliCommand(['git', 'diff'], args, cliOpts)
    cb = util.wrapCallback callback, (err, stdout) -> gitUtil.parseShortDiff(stdout)
    execute command, @_getOptions(), cb

  log: (options={}) ->
    [options, callback] = util.setOptions options, callback
    format = '{"author": "%an", "email": "%ae", "date": "%cd", "subject": "%s", "body": "%b", "hash": "%H"},'
    cliOpts = _.extend({ pretty: "format:#{format}" }, options)
    command = new CliCommand(['git', 'log'], cliOpts)
    cb = util.wrapCallback callback, (err, stdout) -> gitUtil.parseLog(stdout)
    execute command, @_getOptions(), cb

  commit: (message, options, callback) ->
    [options, callback] = util.setOptions options, callback
    cliOpts = _.extend({m: message}, options)
    if options.autoAdd
      cliOpts.a = ''
    command = new CliCommand(['git', 'commit'], cliOpts)
    execute command, @_getOptions(), callback

  _getDiffArgs: (options) ->
    args = []
    args.push options.source if options.source?
    args.push options.target if options.target?
    if options.path?
      args.push '--'
      Array.prototype.push.apply args, options.paths
    args

  listRemotes: (options, callback) ->
    [options, callback] = util.setOptions options, callback
    cb = util.wrapCallback callback, (err, stdout) -> stdout.trim().split "\n"
    command = new CliCommand(['git', 'remote', 'show'], options)
    execute command, @_getOptions(), cb

  showRemote: (name, options, callback) ->
    [options, callback] = util.setOptions options, callback
    cb = util.wrapCallback callback, (err, stdout) -> gitUtil.parseRemote stdout
    command = new CliCommand(['git', 'remote', 'show'], name, options)
    execute command, @_getOptions(), cb

  currentBranch: (options, callback) ->
    [options, callback] = util.setOptions options, callback
    cb = util.wrapCallback callback, (err, stdout) -> gitUtil.parseCurrentBranch stdout
    command = new CliCommand(['git', 'branch'], options)
    execute command, @_getOptions(), cb

  branch: (branch, options, callback) ->
    branch = [branch] if _.isString(branch)
    if _.isArray(branch)
      [[options, callback], hasName] = [util.setOptions(options, callback), true]
    else
      [[options, callback], hasName] = [util.setOptions(branch, options), false]
    branch = [] unless hasName
    cb = util.wrapCallback callback, (err, stdout) -> gitUtil.parseBranches stdout unless hasName
    command = new CliCommand(['git', 'branch'], branch, options)
    execute command, @_getOptions(), cb

  checkout: (branch, options, callback) ->
    [options, callback] = util.setOptions options, callback
    command = new CliCommand(['git', 'checkout'], branch, options)
    execute command, @_getOptions(), callback

  push: (args, options, callback) ->
    args = [args] if _.isString(args)
    if _.isArray(args)
      [options, callback] = util.setOptions(options, callback)
    else
      [[options, callback], args] = [util.setOptions(args, options), []]
    command = new CliCommand(['git', 'push'], args, options)
    execute command, @_getOptions(), callback

  addRemote: (name, url, options, callback) ->
    [options, callback] = util.setOptions options, callback
    command = new CliCommand(['git', 'remote', 'add'], [name, url], options)
    execute command, @_getOptions(), callback

  setRemoteUrl: (name, url, options, callback) ->
    [options, callback] = util.setOptions options, callback
    command = new CliCommand(['git', 'remote', 'set-url'], [name, url], options)
    execute command, @_getOptions(), callback

  merge: (args, options, callback) ->
    [options, callback] = util.setOptions options, callback
    command = new CliCommand(['git', 'merge'], args, options)
    execute command, @_getOptions(), callback

  workingDir: -> path.dirname @path

  _getOptions: ->
    cwd: @workingDir()


module.exports = Repository
