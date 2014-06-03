module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    watch:
      coffee:
        files: 'src/*.coffee'
        tasks: ['coffee:dist', 'mochaTest:test']
      test:
        files: 'test/*.coffee'
        tasks: ['mochaTest:test']

    coffee:
      dist:
        expand: true
        flatten: true
        cwd: 'src'
        src: ['*.coffee']
        dest: 'lib/'
        ext: '.js'

    mochaTest:
      test:
        options:
          require: 'coffee-script/register'
        src: ['test/*.coffee']


  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.registerTask 'test', ['coffee:dist', 'mochaTest:test']

  grunt.registerTask 'default', ['test', 'watch']
