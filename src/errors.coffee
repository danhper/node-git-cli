class GitError extends Error
  constructor: (@message="") ->
    @name = "GitError"
    super @message

class BadRepositoryError extends GitError
  constructor: (@message="") ->
    @name = "BadRepositoryError"
    super @message

module.exports =
  GitError: GitError
  BadRepositoryError: BadRepositoryError
