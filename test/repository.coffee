expect = require 'expect.js'

simpleGit = require('../lib/simple-git')
Repository = simpleGit.Repository

describe 'Repository', ->
  describe 'constructor', ->
    it 'should throw error on wrong path', ->
      fn = -> new Repository('/wrong/path')
      expect(fn).to.throwException (e) ->
        expect(e).to.be.a(simpleGit.BadRepositoryError)

    it 'should set the path', ->
      path = '/path/to/.git'
      repository = new Repository(path)
      expect(repository.path).to.be(path)

  describe 'workingDir', ->
    it 'should return the repository working directory', ->
      repository = new Repository('/path/to/.git')
      expect(repository.workingDir()).to.be('/path/to')
