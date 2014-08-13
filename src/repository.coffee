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
    options = Util.setOptions options, callback
    fs.ensureDirSync path
    command = new CliCommand('git', ['init', path], options.cli)
    if options.callback
      callback = options.callback
      options.callback = (err, stdout, stderr) ->
        repository = new Repository("#{path}/.git")
        callback err, repository
    Runner.execute command, options

  @clone: (url, path, options, callback) ->
    options = Util.setOptions options, callback
    command = new CliCommand(['git', 'clone'], [url, path], options.cli)
    if options.callback
      callback = options.callback
      options.callback = (err, stdout, stderr) ->
        repository = new Repository("#{path}/.git")
        callback err, repository
    Runner.execute command, options

  add: (files, options, callback) ->
    if _.isArray files
      options = Util.setOptions options, callback
    else
      options = Util.setOptions files, options
      files = ['.']
    args = []
    Array.prototype.push.apply(args, files)
    command = new CliCommand(['git', 'add'], args, options.cli)
    Runner.execute command, @_createOptions(options)

  status: (options={}) ->
    options = Util.setOptions options, callback
    command = new CliCommand(['git', 'status'], _.extend({ s: '' }, options.cli))
    if options.callback
      callback = options.callback
      options.callback = (err, stdout, stderr) =>
        statusInfo = GitUtil.parseStatus(stdout)
        _.each(statusInfo, (f) => f.fullPath = "#{@workingDir()}/#{f.path}")
        callback err, statusInfo
    Runner.execute command, @_createOptions(options)

  diff: (options, callback) ->
    options = Util.setOptions options, callback
    args = @_getDiffArgs(options)
    command = new CliCommand(['git', 'diff'], args, options.cli)
    Runner.execute command, @_createOptions(options)

  diffStats: (options={}) ->
    options = Util.setOptions options, callback
    args = @_getDiffArgs(options)
    cliOpts = _.extend({ shortstat: '' }, options.cli)
    command = new CliCommand(['git', 'diff'], args, cliOpts)
    if options.callback
      callback = options.callback
      options.callback = (err, stdout, stderr) ->
        stats = GitUtil.parseShortDiff(stdout)
        callback err, stats
    Runner.execute command, @_createOptions(options)

  log: (options={}) ->
    options = Util.setOptions options, callback
    format = '{"author": "%an", "email": "%ae", "date": "%cd", "subject": "%s", "body": "%b", "hash": "%H"},'
    cliOpts = _.extend({ pretty: "format:#{format}" }, options.cli)
    command = new CliCommand(['git', 'log'], cliOpts)
    if options.callback
      callback = options.callback
      options.callback = (err, stdout, stderr) ->
        logs = GitUtil.parseLog stdout
        callback err, logs
    Runner.execute command, @_createOptions(options)

  commit: (message, options, callback) ->
    options = Util.setOptions options, callback
    cliOpts = _.extend({m: message}, options.cli)
    if options.autoAdd
      cliOpts.a = ''
    command = new CliCommand(['git', 'commit'], cliOpts)
    Runner.execute command, @_createOptions(options)

  _getDiffArgs: (options) ->
    args = []
    args.push options.source if options.source?
    args.push options.target if options.target?
    if options.path?
      args.push '--'
      Array.prototype.push.apply args, options.paths
    args

  listRemotes: (options, callback) ->
    options = Util.setOptions options, callback
    if options.callback
      callback = options.callback
      options.callback = (err, stdout, stderr) ->
        remotes = stdout.trim().split "\n"
        callback err, remotes
    command = new CliCommand(['git', 'remote', 'show'], options.cli)
    Runner.execute command, @_createOptions(options)


  workingDir: -> path.dirname @path

  _createOptions: (base={}) ->
    _.extend
      cwd: @workingDir()
    , base


module.exports = Repository
