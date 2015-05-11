expect = require 'expect.js'

CliOption = require('../src/cli-option')

describe 'CliOption', ->
  describe 'constructor', ->
    it 'should work without arguments', ->
      option = new CliOption('a')
      expect(option.hasArgs).to.be false

    it 'should work with arguments as object', ->
      option = new CliOption({a: '123'})
      expect(option.hasArgs).to.be true
      expect(option.args).to.eql ['123']

    it 'should work with arguments as array', ->
      option = new CliOption(['a', '123'])
      expect(option.hasArgs).to.be true
      expect(option.args).to.eql ['123']

    it 'should work with second argument', ->
      option = new CliOption('a', '123')
      expect(option.hasArgs).to.be true
      expect(option.args).to.eql ['123']

  describe '#toString', ->
    it 'should format short options wihout args', ->
      result = new CliOption('a').toString()
      expect(result).to.be '-a'

    it 'should format long options without args', ->
      result = new CliOption('all').toString()
      expect(result).to.be '--all'

    it 'should format short options with args', ->
      option = new CliOption('m', 'lorem ipsum')
      expected = "-m \"lorem ipsum\""
      expect(option.toString()).to.be expected

    it 'should format long options with args', ->
      option = new CliOption('message', 'lorem ipsum')
      expected = "--message=\"lorem ipsum\""
      expect(option.toString()).to.be expected

    it 'should ignore "true"', ->
      option = new CliOption('verbose', true)
      expected = "--verbose"
      expect(option.toString()).to.be expected
