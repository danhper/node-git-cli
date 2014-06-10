expect = require 'expect.js'

CliOption  = require('../src/cli-option')
CliCommand = require('../src/cli-command')

describe 'CliCommand', ->
  describe 'constructor', ->
    it 'should work with no arguments or options', ->
      command = new CliCommand('foo')
      expect(command.args).to.be undefined
      expect(command.options).to.be undefined

    it 'should work with no options', ->
      command = new CliCommand('foo', 'abc')
      expect(command.args).to.eql ['abc']
      expect(command.options).to.be undefined

      command = new CliCommand('foo', ['abc', 'def'])
      expect(command.args).to.eql ['abc', 'def']
      expect(command.options).to.be undefined

    it 'should work with no arguments', ->
      command = new CliCommand('foo', {abc: 123})
      expect(command.args).to.be undefined
      expect(command.options).to.eql([new CliOption('abc', 123)])

    it 'should work arguments and options', ->
      command = new CliCommand('foo', ['abc', 'def'], {foo: 123, bar: ''})
      expect(command.args).to.eql ['abc', 'def']
      expect(command.options).to.eql [new CliOption('foo', 123), new CliOption('bar')]

  describe '#toString', ->
    it 'should format command with no arguments or options', ->
      command = new CliCommand('ls')
      expect(command.toString()).to.be 'ls'

    it 'should format command with arguments', ->
      command = new CliCommand('git', ['add', '.'])
      expect(command.toString()).to.be 'git add .'

    it 'should format command with options', ->
      command = new CliCommand('pacman', { S: 'abc', verbose: '' })
      expect(command.toString()).to.be "pacman -S 'abc' --verbose"
      command = new CliCommand(['git', 'commit'], { m: 'my message', a: '' })
      expect(command.toString()).to.be "git commit -m 'my message' -a"

    it 'should format command with arguments and options', ->
      command = new CliCommand(['git', 'diff'], ['HEAD~5', 'HEAD', '--', 'README.md'], { s: '' })
      expect(command.toString()).to.be "git diff -s HEAD~5 HEAD -- README.md"

