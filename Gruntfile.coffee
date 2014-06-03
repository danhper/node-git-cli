module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    watch:
      coffee:
        files: 'src/*.coffee'
        tasks: ['test']
      test:
        files: 'test/*.coffee'
        tasks: ['mochacov:test']

    coffee:
      dist:
        expand: true
        flatten: true
        cwd: 'src'
        src: ['*.coffee']
        dest: 'lib/'
        ext: '.js'

    mochacov:
      options:
        compilers: ['coffee:coffee-script/register']
        files: ['test/*.coffee']
      coverage:
        options:
          coveralls: true
      test:
        options:
          reporter: 'dot'


  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-mocha-cov'

  grunt.registerTask 'test', ['coffee:dist', 'mochacov:test']
  grunt.registerTask 'coverage', ['coffee:dist', 'mochacov:coverage']

  grunt.registerTask 'default', ['test', 'watch']
