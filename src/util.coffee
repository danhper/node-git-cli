_ = require 'underscore'
S = require 'string'

Util =
  hasType: (object, type) ->
    object.constructor.name == type.name

  checkArgs: (object, allowedTypes) ->
    allowedTypes = [allowedTypes] unless _.isArray allowedTypes
    valid = false
    for type in allowedTypes
      break if valid = Util.hasType object, type
    unless valid
      allowedTypesString = _.map(allowedTypes, (t) -> t.name).join ', '
      throw new TypeError("expected #{allowedTypesString} but got #{object.constructor.name}")
    true

  escape: (s, chars=['"', "'"], escapeChar="\\") ->
    regexp = new RegExp("([#{chars.join('')}])", 'g')
    s.replace regexp, "#{escapeChar}$1"

  surroundSingleQuote: (s) ->
    s.replace /'/g, "'\"'\"'"

  quote: (value, escape=false) ->
    value = value.replace(/'/g, "\\'") if escape
    "'#{value}'"

  quoteAll: (values) ->
    _.map values, (value) =>
      @quote value

  setOptions: (options, callback) ->
    if _.isFunction(options) && !callback?
      options = { callback: options }
    else
      options ?= {}
      options.callback = callback ? null
    options

module.exports = Util
