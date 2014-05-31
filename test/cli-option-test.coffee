expect = require 'expect.js'

CliOption = require('../lib/cli-option')

describe 'CliOption', ->
  describe '#toString', ->
    it 'should format short options wihout args', ->
      result = new CliOption('a').toString()
      expect(result).to.be '-a'

    it 'should format long options without args', ->
      result = new CliOption('all').toString()
      expect(result).to.be '--all'

    it 'should format short options with args', ->
      option = new CliOption('m', 'lorem ipsum')
      expected = "-m 'lorem ipsum'"
      expect(option.toString()).to.be expected

    it 'should format long options with args', ->
      option = new CliOption('message', 'lorem ipsum')
      expected = "--message='lorem ipsum'"
      expect(option.toString()).to.be expected
