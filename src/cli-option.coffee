_    = require 'underscore'

Util = require './util'

class CliOption
  constructor: (option, args) ->
    Util.checkArgs option, [Array, String, Object]
    if _.isUndefined args && _.isString option
      @option = option
      @hasArgs = false
    else
      @_initWithArguments option, args

  _initWithArguments: (option, args) ->
    if _.isUndefined args
      option = _.pairs option if _.isObject option
      if option.length != 1
        throw new TypeError("options object should be a single key/value pair")
      [@option, @args] = option[0]
    else
      [@option, @args] = [option, args]
    Util.checkArgs @args, [Array, String]
    @args = [@args] unless _.isArray @args

    @hasArgs = true

  toString: ->
    if @hasArgs
      @_formatOptionWithArgs()
    else
      @_formatSimpleOption()

  _formatSimpleOption: ->
    prefix = if @option.length == 1 then '-' else '--'
    prefix + @option

  _formatOptionWithArgs: ->
    argsString = Util.quoteAll(@args).join ' '
    if @option.length == 1
      "-#{@option} #{argsString}"
    else
      "--#{@option}=#{argsString}"

module.exports = CliOption
