process.env['TMPDIR'] = '/tmp/node-simple-git'

_      = require 'underscore'
expect = require 'expect.js'
tmp    = require 'tmp'
fs     = require 'fs-extra'

simpleGit  = require('../src/simple-git')
Repository = require('../src/repository')
CliOption  = require('../src/cli-option')


testRepository = null

before (done) ->
  if fs.existsSync(process.env['TMPDIR'])
    fs.removeSync(process.env['TMPDIR'])
  fs.mkdirSync(process.env['TMPDIR'])
  tmp.dir (err, path) ->
    Repository.clone 'https://github.com/tuvistavie/node-simple-git', "#{path}/node-simple-git",
      onSuccess: (repository) ->
        testRepository = repository
        done()

after ->
  fs.removeSync(process.env['TMPDIR'])

describe 'Repository', ->

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
      tmp.dir { unsafeCleanup: true }, (err, path) ->
        Repository.clone testRepository.path, "#{path}/node-simple-git",
          onSuccess: (repository) ->
            expect(repository.path).to.eql "#{path}/node-simple-git/.git"
            Repository.clone testRepository.path, "#{path}/node-simple-git",
              onError: (error) ->
                expect(error).to.not.be null
                done()

  describe '#add', ->
    it 'should add given files', (done) ->
      done()

  describe '#status', ->
    it 'get file status', (done) ->
      fs.openSync("#{testRepository.workingDir()}/foo", 'w')
      testRepository.status
        onSuccess: (changes) ->
          _.each ['addedFiles', 'editedFiles', 'removedFiles', 'untrackedFiles'], (fileType) ->
            expect(changes[fileType]).to.be.an Array
          done()
