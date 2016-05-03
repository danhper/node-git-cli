process.env['TMPDIR'] = '/tmp/node-git-cli'

_      = require 'underscore'
expect = require 'expect.js'
tmp    = require 'tmp'
fs     = require 'fs-extra'

Helpers    = require './test-helpers'
gitCli     = require '../src/git-cli'
Repository = require '../src/repository'
CliOption  = require '../src/cli-option'

BASE_REPO_PATH = '/home/daniel/Documents/projects/node-git-cli'
unless fs.existsSync BASE_REPO_PATH
  BASE_REPO_PATH = 'https://github.com/tuvistavie/node-git-cli.git'

[baseRepository, testRepository]  = [null, null]

before () ->
  if fs.existsSync(process.env['TMPDIR'])
    fs.removeSync(process.env['TMPDIR'])
  fs.mkdirSync(process.env['TMPDIR'])
  path = tmp.dirSync().name
  Repository.clone(BASE_REPO_PATH, "#{path}/node-git-cli", { bare: true })
    .then((repo) -> baseRepository = repo)

after ->
  fs.removeSync(process.env['TMPDIR'])

describe 'Repository', ->
  beforeEach () ->
    path = tmp.dirSync().name
    Repository.clone(baseRepository.workingDir(), "#{path}/node-git-cli")
      .then((repo) -> testRepository = repo)

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

  describe '#_getOptions', ->
    it 'should return "cwd"', ->
      repository = new Repository('/path/to/.git')
      expect(repository._getOptions()).to.eql { cwd: '/path/to' }

  describe 'clone', ->
    it 'should clone repository to given directory', (done) ->
      path = tmp.dirSync({unsafeCleanup: true}).name
      Repository.clone(testRepository.path, "#{path}/node-git-cli")
        .then((repo) ->
          expect(repo.path).to.eql "#{path}/node-git-cli/.git"
          Repository.clone(testRepository.path, "#{path}/node-git-cli"))
        .then(-> done(new Error('should not be able to clone in existing dir')))
        .catch((e) -> done())

  describe 'init', ->
    it 'should init a new repository to given directory', () ->
      path = tmp.dirSync().name
      Repository.init("#{path}/node-git-cli")
        .then((repo) -> expect(repo.path).to.eql "#{path}/node-git-cli/.git")

  describe '#status', ->
    it 'get file status', () ->
      addedFilePath = "#{testRepository.workingDir()}/foo"
      editedFilePath = "#{testRepository.workingDir()}/README.md"
      fs.openSync(addedFilePath, 'w')
      fs.appendFileSync(editedFilePath, 'foobar')
      testRepository.status().then (changes) ->
        expect(changes).to.be.an Array
        expect(changes.length).to.be 2
        _.each { path: 'README.md', fullPath: editedFilePath, status: 'modified', tracked: false }, (v, k) ->
          expect(changes[0][k]).to.be v
        _.each { path: 'foo', fullPath: addedFilePath, status: 'added', tracked: false }, (v, k) ->
          expect(changes[1][k]).to.be v

  describe '#add', ->
    it 'should add all files by default', () ->
      fs.openSync("#{testRepository.workingDir()}/foo", 'w')
      fs.appendFileSync("#{testRepository.workingDir()}/README.md", 'foobar')
      testRepository.add()
        .then(-> testRepository.status())
        .then (changes) ->
          expect(changes.length).to.be 2
          _.each changes, (change) ->
            expect(change.tracked).to.be true

    it 'shoud add given files otherwise', () ->
      addedFilePath = "#{testRepository.workingDir()}/foo"
      fs.openSync(addedFilePath, 'w')
      fs.appendFileSync("#{testRepository.workingDir()}/README.md", 'foobar')
      testRepository.add([addedFilePath])
        .then(-> testRepository.status())
        .then (changes) ->
           expect(changes.length).to.be(2)
           expect(changes[0].tracked).to.be(false)
           expect(changes[1].tracked).to.be(true)

  describe '#diff', ->
    it 'should not return output when files are not changed', () ->
      testRepository.diff().then((output) -> expect(output).to.be.empty())

    it 'should return output when files are changed', () ->
      fs.appendFileSync("#{testRepository.workingDir()}/README.md", 'foobar')
      testRepository.diff().then((output) -> expect(output).to.not.be.empty())

  describe '#diffStats', ->
    it 'should return correct stats', () ->
      fs.appendFileSync("#{testRepository.workingDir()}/README.md", 'foobar')
      Helpers.removeFirstLine("#{testRepository.workingDir()}/LICENSE")
      testRepository.diffStats().then (stats) ->
        expect(stats).to.be.a Object
        _.each { changedFilesNumber: 2, insertions: 1, deletions: 1}, (v, k) ->
          expect(stats[k]).to.be v

  describe '#log', ->
    it 'should return logs', () ->
      testRepository.log().then (logs) ->
        expect(logs).to.be.an Array
        expect(logs).to.not.be.empty()
        keys = ['author', 'email', 'subject', 'body', 'date', 'hash']
        expect(logs[0]).to.only.have.keys keys
        expect(logs[0].date).to.be.a Date

    it 'should accept options and return logs', () ->
      testRepository.log({ n: 1 }).then (logs) ->
        expect(logs).to.be.an Array
        expect(logs).to.have.length 1

  describe '#commit', ->
    it 'should work when files are added', () ->
      fs.appendFileSync("#{testRepository.workingDir()}/README.md", 'foobar')
      testRepository.log().then (logs) ->
        logsCount = logs.length
        testRepository.add()
          .then(-> testRepository.commit "foo'bar")
          .then(-> testRepository.log())
          .then((logs) -> expect(logs.length).to.be (logsCount + 1))

  describe '#listRemotes', ->
    it 'should list all remotes', () ->
      testRepository.listRemotes().then((remotes) -> expect(remotes).to.eql(['origin']))

  describe '#showRemote', ->
    it 'should get remote info', () ->
      testRepository.showRemote('origin').then (info) ->
        expected =
          pushUrl: baseRepository.workingDir()
          fetchUrl: baseRepository.workingDir()
          headBranch: 'master'
        expect(info).to.eql expected

  describe '#currentBranch', ->
    it 'should return current branch', () ->
      testRepository.currentBranch().then((branch) -> expect(branch).to.be 'master')

  describe '#branch', ->
    it 'should list branches', () ->
      testRepository.branch().then((branches) -> expect(branches).to.eql ['master'])

    it 'should create new branches', () ->
      testRepository.branch('foo')
        .then(-> testRepository.branch())
        .then((branches) -> expect(branches).to.eql ['foo', 'master'])

    it 'should delete branches', () ->
      testRepository.branch('foo')
        .then(-> testRepository.branch())
        .then((branches) ->
          expect(branches).to.eql ['foo', 'master']
          testRepository.branch('foo', { D: true }))
        .then(-> testRepository.branch())
        .then((branches) -> expect(branches).to.eql ['master'])

  describe '#checkout', ->
    it 'should do basic branch checkout', () ->
      testRepository.currentBranch()
       .then((branch) ->
          expect(branch).to.be 'master'
          testRepository.branch('gh-pages'))
       .then(-> testRepository.checkout 'gh-pages')
       .then(-> testRepository.currentBranch())
       .then((branch) -> expect(branch).to.be('gh-pages'))

    it 'should work with -b flag', () ->
      testRepository.checkout('foo', { b: true })
        .then(-> testRepository.currentBranch())
        .then((branch) -> expect(branch).to.be 'foo')

  describe '#push', ->
    it 'should push commits', () ->
      fs.appendFileSync("#{testRepository.workingDir()}/README.md", 'foobar')
      baseRepository.log()
        .then (logs) ->
          logsCount = logs.length
          testRepository.commit("foo'bar", { a: true })
            .then(-> testRepository.push())
            .then(-> baseRepository.log())
            .then((logs) -> expect(logs.length).to.be logsCount + 1)

  describe '#pull', ->
    it 'should pull commits', () ->
      path = tmp.dirSync().name
      Promise.all([
        Repository.clone(baseRepository.workingDir(), "#{path}/node-git-cli-other"),
        testRepository.log()
      ]).then (result) ->
        [repo, logs] = result
        logsCount = logs.length
        fs.appendFileSync("#{repo.workingDir()}/README.md", 'foobarbaz')
        repo.commit("foobarbaz", { a: true })
          .then(-> repo.push())
          .then(-> testRepository.pull())
          .then(-> testRepository.log())
          .then((logs) -> expect(logs.length).to.be logsCount + 1)

  describe '#addRemote', ->
    it 'should add new remote', () ->
      testRepository.addRemote('foo', baseRepository.path)
        .then(-> testRepository.listRemotes())
        .then((remotes) -> expect(remotes).to.contain('foo'))

  describe '#setRemoteUrl', ->
    it 'should change remote URL', () ->
      testRepository.setRemoteUrl('origin', 'newUrl')
        .then(-> testRepository.showRemote('origin', { n: true }))
        .then((remote) -> expect(remote.pushUrl).to.be('newUrl'))

  describe '#merge', ->
    it 'should merge branche', () ->
      file = "#{testRepository.workingDir()}/README.md"
      fs.appendFileSync(file, 'random string')
      testRepository.branch('newbranch')
        .then(-> testRepository.add())
        .then(-> testRepository.commit("new commit"))
        .then(-> testRepository.checkout('newbranch'))
        .then(->
           expect(fs.readFileSync(file, 'utf8')).to.not.contain 'random string'
           testRepository.merge('master'))
        .then(->
           expect(fs.readFileSync(file, 'utf8')).to.contain 'random string'
           testRepository.log())
        .then((logs) -> expect(logs[0].subject).to.be('new commit'))

  describe 'usage with callbacks', ->
    it 'should accept a callback', (done) ->
      testRepository.log (err, logs) ->
        expect(err).to.be.null
        expect(logs).to.be.an Array
        expect(logs).to.not.be.empty()
        keys = ['author', 'email', 'subject', 'body', 'date', 'hash']
        expect(logs[0]).to.only.have.keys keys
        expect(logs[0].date).to.be.a Date
        done()
