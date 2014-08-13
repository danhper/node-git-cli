process.env['TMPDIR'] = '/tmp/node-git-cli'

_      = require 'underscore'
expect = require 'expect.js'
tmp    = require 'tmp'
fs     = require 'fs-extra'

Helpers    = require './test-helpers'
gitCli  = require '../src/git-cli'
Repository = require '../src/repository'
CliOption  = require '../src/cli-option'

BASE_REPO_PATH = '/home/daniel/Documents/projects/node-git-cli'
unless fs.existsSync BASE_REPO_PATH
  BASE_REPO_PATH = 'https://github.com/tuvistavie/node-git-cli.git'

[baseRepository, testRepository]  = [null, null]

before (done) ->
  if fs.existsSync(process.env['TMPDIR'])
    fs.removeSync(process.env['TMPDIR'])
  fs.mkdirSync(process.env['TMPDIR'])
  tmp.dir (err, path) ->
    Repository.clone BASE_REPO_PATH, "#{path}/node-git-cli", (err, repo) ->
        baseRepository = repo
        done()

after ->
  fs.removeSync(process.env['TMPDIR'])

describe 'Repository', ->
  beforeEach (done) ->
    tmp.dir (err, path) ->
      Repository.clone baseRepository.path, "#{path}/node-git-cli", (err, repo) ->
          testRepository = repo
          done()

  describe 'constructor', ->
    it 'should throw error on wrong path', ->
      fn = -> new Repository('/wrong/path')
      expect(fn).to.throwException (e) ->
        expect(e).to.be.a gitCli.BadRepositoryError

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
        Repository.clone testRepository.path, "#{path}/node-git-cli", (err, repo) ->
          expect(err).to.be null
          expect(repo.path).to.eql "#{path}/node-git-cli/.git"
          Repository.clone testRepository.path, "#{path}/node-git-cli", (err, repo) ->
            expect(err).to.not.be null
            done()

  describe 'init', ->
    it 'should init a new repository to given directory', (done) ->
      tmp.dir { unsafeCleanup: true }, (err, path) ->
        Repository.init "#{path}/node-git-cli", (err, repository) ->
          expect(err).to.be null
          expect(repository.path).to.eql "#{path}/node-git-cli/.git"
          done()

  describe '#status', ->
    it 'get file status', (done) ->
      addedFilePath = "#{testRepository.workingDir()}/foo"
      editedFilePath = "#{testRepository.workingDir()}/README.md"
      fs.openSync(addedFilePath, 'w')
      fs.appendFileSync(editedFilePath, 'foobar')
      testRepository.status (err, changes) ->
        expect(err).to.be null
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
      testRepository.add (err) ->
          expect(err).to.be null
          testRepository.status (err, changes) ->
              expect(changes.length).to.be 2
              _.each changes, (change) ->
                expect(change.tracked).to.be true
              done()

    it 'shoud add given files otherwise', (done) ->
      addedFilePath = "#{testRepository.workingDir()}/foo"
      fs.openSync(addedFilePath, 'w')
      fs.appendFileSync("#{testRepository.workingDir()}/README.md", 'foobar')
      testRepository.add [addedFilePath], (err) ->
        expect(err).to.be null
        testRepository.status (err, changes) ->
            expect(changes.length).to.be 2
            expect(changes[0].tracked).to.be false
            expect(changes[1].tracked).to.be true
            done()

  describe '#diff', ->
    it 'should not return output when files are not changed', (done) ->
      testRepository.diff (err, output) ->
        expect(err).to.be null
        expect(output).to.be.empty()
        done()

    it 'should return output when files are changed', (done) ->
      fs.appendFileSync("#{testRepository.workingDir()}/README.md", 'foobar')
      testRepository.diff (err, output) ->
        expect(err).to.be null
        expect(output).to.not.be.empty()
        done()

  describe '#diffStats', ->
    it 'should return correct stats', (done) ->
      fs.appendFileSync("#{testRepository.workingDir()}/README.md", 'foobar')
      Helpers.removeFirstLine("#{testRepository.workingDir()}/LICENSE")
      testRepository.diffStats (err, stats) ->
        expect(err).to.be null
        expect(stats).to.be.a Object
        _.each { changedFilesNumber: 2, insertions: 1, deletions: 1}, (v, k) ->
          expect(stats[k]).to.be v
        done()

  describe '#log', ->
    it 'should return logs', (done) ->
      testRepository.log (err, logs) ->
        expect(err).to.be null
        expect(logs).to.be.an Array
        expect(logs).to.not.be.empty()
        keys = ['author', 'email', 'subject', 'body', 'date', 'hash']
        expect(logs[0]).to.only.have.keys keys
        expect(logs[0].date).to.be.a Date
        done()

  describe '#commit', ->
    it 'should work when files are added', (done) ->
      fs.appendFileSync("#{testRepository.workingDir()}/README.md", 'foobar')
      testRepository.log (err, logs) ->
        logsCount = logs.length
        testRepository.add (err) ->
          testRepository.commit "foo'bar", (err) ->
            expect(err).to.be null
            testRepository.log (err, logs) ->
              expect(logs.length).to.be (logsCount + 1)
              done()

  describe '#listRemotes', ->
    it 'should list all remotes', (done) ->
      testRepository.listRemotes (err, remotes) ->
        expect(err).to.be null
        expect(remotes).to.eql(['origin'])
        done()

  describe '#showRemote', ->
    it 'should get remote info', (done) ->
      testRepository.showRemote 'origin', (err, info) ->
        expected =
          pushUrl: baseRepository.path
          fetchUrl: baseRepository.path
          headBranch: 'master'
        expect(info).to.eql expected
        done()
