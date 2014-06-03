_         = require 'underscore'

Util      = require './util'
CliOption = require './cli-option'

class CliCommand
  constructor: (@command, @args, options) ->
    unless options? || _.isString(@args) || _.isArray(@args)
      options = @args
      @args = undefined

    Util.checkArgs @command, String
    Util.checkArgs @args, [String, Array] if @args?
    Util.checkArgs options, [Array, Object] if options?

    @args = [@args] if _.isString(@args)
    if options?
      options = _.pairs(options) unless _.isArray(options)
      @options = _.map options, ((opt) => @_initOption(opt))

  _initOption: (option) ->
    Util.checkArgs option, [Array, CliOption]
    return option if Util.hasType(option, CliOption)
    if option.length != 2
      throw new TypeError("options object should be a single key/value pair")
    if _.isUndefined(option[1]) || option[1] == ''
      new CliOption(option[0])
    else
      new CliOption(option[0], option[1])

  toString: ->
    s = @command + ' '
    s += @args.join(' ') + ' ' if @args?
    s += _.map(@options, (opt) -> opt.toString()).join(' ')
    s.trim()


module.exports = CliCommand
