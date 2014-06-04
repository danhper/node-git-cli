expect = require 'expect.js'
tmp    = require 'tmp'
fs     = require 'fs'

simpleGit  = require('../src/simple-git')
Repository = require('../src/repository')
CliOption  = require('../src/cli-option')

describe 'Repository', ->
  before ->
    tmp.dir (err, path) ->
      Repository.clone 'https://github.com/tuvistavie/node-simple-git', "#{path}/node-simple-git",

  describe 'constructor', ->
    it 'should throw error on wrong path', ->
      fn = -> new Repository('/wrong/path')
      expect(fn).to.throwException (e) ->
        expect(e).to.be.a simpleGit.BadRepositoryError

    it 'should set the path', ->
      path = '/path/to/.git'
      repository = new Repository(path)
      expect(repository.path).to.be path

  describe 'workingDir', ->
    it 'should return the repository working directory', ->
      repository = new Repository('/path/to/.git')
      expect(repository.workingDir()).to.be '/path/to'

  describe '#createOptions', ->
    it 'should extend options with "cwd"', ->
      repository = new Repository('/path/to/.git')
      options = { foo: 'bar' }
      expect(repository._createOptions(options)).to.eql { cwd: '/path/to', foo: 'bar' }

  describe 'clone', ->
    it 'should clone repository to given directory', (done) ->
      @timeout(10000)
      tmp.dir { unsafeCleanup: true }, (err, path) ->
        Repository.clone 'https://github.com/tuvistavie/node-simple-git', "#{path}/node-simple-git",
          onSuccess: (repository) ->
            expect(repository.path).to.eql "#{path}/node-simple-git/.git"
            Repository.clone 'https://github.com/tuvistavie/node-simple-git', "#{path}/node-simple-git",
              onError: (error) ->
                expect(error).to.not.be null
                done()

  describe '#add', ->
    it 'should add given files', (done) ->
      @timeout(10000)
      tmp.dir { unsafeCleanup: true }, (err, path) ->
        Repository.clone 'https://github.com/tuvistavie/node-simple-git', "#{path}/node-simple-git",
          onSuccess: (repository) ->
            done()

  describe '#status', ->
    it 'get file status', (done) ->
      @timeout(10000)
      tmp.dir { unsafeCleanup: true }, (err, path) ->
        Repository.clone 'https://github.com/tuvistavie/node-simple-git', "#{path}/node-simple-git",
          onSuccess: (repository) ->
            repository.status()
            done()

  inRepo = (f) ->
