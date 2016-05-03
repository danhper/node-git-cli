# node-git-cli [![Build Status][travis-img]][travis-build] [![Coverage Status][coveralls]][coveralls-img]

A simple git interface for NodeJS.
It is not intended to replace projects such as 
[nodegit](https://github.com/nodegit/nodegit) but 
rather to provide a light weight solution close to 
the git command line for simple use cases.

## Installation

Just run

```
$ npm install git-cli
```

## Usage

The usage is pretty straightforward, here is a sample code.

```coffee
Repository = require('git-cli').Repository
fs = require 'fs'

Repository.clone 'https://github.com/tuvistavie/node-git-cli', 'git-cli', (err, repo) ->
  repo.log (err, logs) ->
    console.log logs[0].subject
    repo.showRemote 'origin', (err, remote) ->
      console.log remote.fetchUrl

      fs.writeFileSync "#{repo.workingDir()}/newFile", 'foobar'
      repo.status (err, status) ->
        console.log status[0].path
        console.log status[0].tracked

        repo.add (err) ->
          repo.status (err, status) ->
            console.log status[0].path
            console.log status[0].tracked

            repo.commit 'added newFile', (err) ->
              repo.log (err, logs) ->
                console.log logs[0].subject

              repo.push (err) ->
                console.log 'pushed to remote'
```

From version 0.10, all functions still take a callback, but also return promises,
so you can rewrite the above as follow:

```javascript
const Repository = require('git-cli').Repository
const fs = require('fs')

Repository.clone('https://github.com/tuvistavie/node-git-cli', 'git-cli')
  .then(repo => {
    return repo.log()
      .then(logs => {
        console.log(logs[0].subject)
        return repo.showRemote('origin')
    }).then(remote => {
        console.log(remote.fetchUrl)
        fs.writeFileSync("#{repo.workingDir()}/newFile", 'foobar')
        return repo.status()
    }).then(status => {
        console.log(status[0].path)
        console.log(status[0].tracked)
        return repo.add()
    }).then(() => repo.status())
      .then(status => {
        console.log status[0].path
        console.log status[0].tracked
        return repo.commit('added newFile')
    }).then(() => repo.log())
      .then(logs => {
        console.log(logs[0].subject)
        return repo.push()
    }).then(() => console.log('pushed' to remote))
  }).catch(e => console.log(e))
```

Checkout out [the tests](test/repository-test.coffee) for more examples.

[travis-build]: https://travis-ci.org/tuvistavie/node-git-cli
[travis-img]: https://travis-ci.org/tuvistavie/node-git-cli.svg?branch=master
[coveralls]: https://coveralls.io/repos/tuvistavie/node-git-cli/badge.png?branch=master
[coveralls-img]: https://coveralls.io/r/tuvistavie/node-git-cli?branch=master
