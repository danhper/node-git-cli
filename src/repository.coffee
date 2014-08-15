fs     = require 'fs-extra'
S      = require 'string'
_      = require 'underscore'
path   = require 'path'

errors      = require './errors'
CliCommand  = require './cli-command'
CliOption   = require './cli-option'
Runner      = require './runner'
Util        = require './util'
GitUtil     = require './git-util'

class Repository
  BAD_PATH_MSG = "repository path should point .git directory"

  constructor: (@path) ->
    unless S(@path).endsWith('.git')
      throw new errors.BadRepositoryError(BAD_PATH_MSG)

  @init: (path, options, callback) ->
    [options, callback] = Util.setOptions options, callback
    fs.ensureDirSync path
    command = new CliCommand('git', ['init', path], options)
    if callback
      done = callback
      callback = (err, stdout, stderr) ->
        repository = new Repository("#{path}/.git")
        done err, repository
    Runner.execute command, {}, callback

  @clone: (url, path, options, callback) ->
    [options, callback] = Util.setOptions options, callback
    command = new CliCommand(['git', 'clone'], [url, path], options)
    if callback
      done = callback
      callback = (err, stdout, stderr) ->
        repository = new Repository("#{path}/.git")
        done err, repository
    Runner.execute command, {}, callback

  add: (files, options, callback) ->
    if _.isArray files
      [options, callback] = Util.setOptions options, callback
    else
      [options, callback] = Util.setOptions files, options
      files = ['.']
    args = []
    Array.prototype.push.apply(args, files)
    command = new CliCommand(['git', 'add'], args, options)
    Runner.execute command, @_getOptions(), callback

  status: (options, callback) ->
    [options, callback] = Util.setOptions options, callback
    command = new CliCommand(['git', 'status'], _.extend({ s: '' }, options))
    if callback?
      done = callback
      callback = (err, stdout, stderr) =>
        statusInfo = GitUtil.parseStatus(stdout)
        _.each(statusInfo, (f) => f.fullPath = "#{@workingDir()}/#{f.path}")
        done err, statusInfo
    Runner.execute command, @_getOptions(), callback

  diff: (options, callback) ->
    [options, callback] = Util.setOptions options, callback
    args = @_getDiffArgs(options)
    command = new CliCommand(['git', 'diff'], args, options)
    Runner.execute command, @_getOptions(), callback

  diffStats: (options, callback) ->
    [options, callback] = Util.setOptions options, callback
    args = @_getDiffArgs(options)
    cliOpts = _.extend({ shortstat: '' }, options)
    command = new CliCommand(['git', 'diff'], args, cliOpts)
    if callback
      done = callback
      callback = (err, stdout, stderr) ->
        stats = GitUtil.parseShortDiff(stdout)
        done err, stats
    Runner.execute command, @_getOptions(), callback

  log: (options={}) ->
    [options, callback] = Util.setOptions options, callback
    format = '{"author": "%an", "email": "%ae", "date": "%cd", "subject": "%s", "body": "%b", "hash": "%H"},'
    cliOpts = _.extend({ pretty: "format:#{format}" }, options)
    command = new CliCommand(['git', 'log'], cliOpts)
    if callback
      done = callback
      callback = (err, stdout, stderr) ->
        logs = GitUtil.parseLog stdout
        done err, logs
    Runner.execute command, @_getOptions(), callback

  commit: (message, options, callback) ->
    [options, callback] = Util.setOptions options, callback
    cliOpts = _.extend({m: message}, options)
    if options.autoAdd
      cliOpts.a = ''
    command = new CliCommand(['git', 'commit'], cliOpts)
    Runner.execute command, @_getOptions(), callback

  _getDiffArgs: (options) ->
    args = []
    args.push options.source if options.source?
    args.push options.target if options.target?
    if options.path?
      args.push '--'
      Array.prototype.push.apply args, options.paths
    args

  listRemotes: (options, callback) ->
    [options, callback] = Util.setOptions options, callback
    if callback
      done = callback
      callback = (err, stdout, stderr) ->
        remotes = stdout.trim().split "\n"
        done err, remotes
    command = new CliCommand(['git', 'remote', 'show'], options)
    Runner.execute command, @_getOptions(), callback

  showRemote: (name, options, callback) ->
    [options, callback] = Util.setOptions options, callback
    if callback?
      done = callback
      callback = (err, stdout, stderr) ->
        remoteInfo = GitUtil.parseRemote stdout
        done err, remoteInfo
    command = new CliCommand(['git', 'remote', 'show'], name, options)
    Runner.execute command, @_getOptions(), callback

  currentBranch: (options, callback) ->
    [options, callback] = Util.setOptions options, callback
    if callback
      done = callback
      callback = (err, stdout, stderr) ->
        branch = GitUtil.parseCurrentBranch stdout
        done err, branch
    command = new CliCommand(['git', 'branch'], options)
    Runner.execute command, @_getOptions(), callback

  branch: (branch, options, callback) ->
    branch = [branch] if _.isString(branch)
    if _.isArray(branch)
      [[options, callback], hasName] = [Util.setOptions(options, callback), true]
    else
      [[options, callback], hasName] = [Util.setOptions(branch, options), false]
    branch = [] unless hasName
    if callback? && !hasName
      done = callback
      callback = (err, stdout, stderr) ->
        branches = GitUtil.parseBranches stdout
        done err, branches
    command = new CliCommand(['git', 'branch'], branch, options)
    Runner.execute command, @_getOptions(), callback

  checkout: (branch, options, callback) ->
    [options, callback] = Util.setOptions options, callback
    command = new CliCommand(['git', 'checkout'], branch, options)
    Runner.execute command, @_getOptions(), callback

  push: (args, options, callback) ->
    args = [args] if _.isString(args)
    if _.isArray(args)
      [options, callback] = Util.setOptions(options, callback)
    else
      [[options, callback], args] = [Util.setOptions(args, options), []]
    command = new CliCommand(['git', 'push'], args, options)
    Runner.execute command, @_getOptions(), callback


  workingDir: -> path.dirname @path

  _getOptions: ->
    cwd: @workingDir()


module.exports = Repository
