fs     = require 'fs-extra'

Helpers =
  removeFirstLine: (file) ->
    content = fs.readFileSync(file).toString()
    lines = content.split '\n'
    newContent = lines[1..].join '\n'
    fs.writeFileSync file, newContent

module.exports = Helpers
