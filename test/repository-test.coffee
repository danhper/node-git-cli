process.env['TMPDIR'] = '/tmp/node-simple-git'

_      = require 'underscore'
expect = require 'expect.js'
tmp    = require 'tmp'
fs     = require 'fs-extra'

Helpers    = require './test-helpers'
simpleGit  = require '../src/simple-git'
Repository = require '../src/repository'
CliOption  = require '../src/cli-option'

BASE_REPO_PATH = '/home/daniel/Documents/projects/node-simple-git'
unless fs.existsSync BASE_REPO_PATH
  BASE_REPO_PATH = 'https://github.com/tuvistavie/node-simple-git.git'

[baseRepository, testRepository]  = [null, null]

before (done) ->
  if fs.existsSync(process.env['TMPDIR'])
    fs.removeSync(process.env['TMPDIR'])
  fs.mkdirSync(process.env['TMPDIR'])
  tmp.dir (err, path) ->
    Repository.clone BASE_REPO_PATH, "#{path}/node-simple-git",
      onSuccess: (repository) ->
        baseRepository = repository
        done()

after ->
  fs.removeSync(process.env['TMPDIR'])

describe 'Repository', ->
  beforeEach (done) ->
    tmp.dir (err, path) ->
      Repository.clone baseRepository.path, "#{path}/node-simple-git",
        onSuccess: (repository) ->
          testRepository = repository
          done()

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

  describe 'init', ->
    it 'should init a new repository to given directory', (done) ->
      tmp.dir { unsafeCleanup: true }, (err, path) ->
        Repository.init "#{path}/node-simple-git",
          onSuccess: (repository) ->
            expect(repository.path).to.eql "#{path}/node-simple-git/.git"
            done()

  describe '#status', ->
    it 'get file status', (done) ->
      addedFilePath = "#{testRepository.workingDir()}/foo"
      editedFilePath = "#{testRepository.workingDir()}/README.md"
      fs.openSync(addedFilePath, 'w')
      fs.appendFileSync(editedFilePath, 'foobar')
      testRepository.status
        onSuccess: (changes) ->
          expect(changes).to.be.an Array
          expect(changes.length).to.be 2
          _.each { path: 'README.md', fullPath: editedFilePath, status: 'modified', tracked: false }, (v, k) ->
            expect(changes[0][k]).to.be v
          _.each { path: 'foo', fullPath: addedFilePath, status: 'added', tracked: false }, (v, k) ->
            expect(changes[1][k]).to.be v
          done()

  describe '#add', ->
    it 'should add all files by default', (done) ->
      fs.openSync("#{testRepository.workingDir()}/foo", 'w')
      fs.appendFileSync("#{testRepository.workingDir()}/README.md", 'foobar')
      testRepository.add
        onSuccess: ->
          testRepository.status
            onSuccess: (changes) ->
              expect(changes.length).to.be 2
              _.each changes, (change) ->
                expect(change.tracked).to.be true
              done()

    it 'shoud add given files otherwise', (done) ->
      addedFilePath = "#{testRepository.workingDir()}/foo"
      fs.openSync(addedFilePath, 'w')
      fs.appendFileSync("#{testRepository.workingDir()}/README.md", 'foobar')
      testRepository.add [addedFilePath],
        onSuccess: ->
          testRepository.status
            onSuccess: (changes) ->
              expect(changes.length).to.be 2
              expect(changes[0].tracked).to.be false
              expect(changes[1].tracked).to.be true
              done()

  describe '#diff', ->
    it 'should not return output when files are not changed', (done) ->
      testRepository.diff
        onSuccess: (output) ->
          expect(output).to.be.empty()
          done()

    it 'should return output when files are changed', (done) ->
      fs.appendFileSync("#{testRepository.workingDir()}/README.md", 'foobar')
      testRepository.diff
        onSuccess: (output) ->
          expect(output).to.not.be.empty()
          done()

  describe '#diffStats', ->
    it 'should return correct stats', (done) ->
      fs.appendFileSync("#{testRepository.workingDir()}/README.md", 'foobar')
      Helpers.removeFirstLine("#{testRepository.workingDir()}/LICENSE")
      testRepository.diffStats
        onSuccess: (stats) ->
          expect(stats).to.be.a Object
          _.each { changedFilesNumber: 2, insertions: 1, deletions: 1}, (v, k) ->
            expect(stats[k]).to.be v
          done()

  describe '#log', ->
    it 'should return logs', (done) ->
      testRepository.log
        onSuccess: (logs) ->
          expect(logs).to.be.an Array
          expect(logs).to.not.be.empty()
          keys = ['author', 'email', 'subject', 'body', 'date', 'hash']
          expect(logs[0]).to.only.have.keys keys
          done()
