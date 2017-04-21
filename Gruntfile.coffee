#
# Crafting Guide - Gruntfile.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

module.exports = (grunt)->

    grunt.loadTasks tasks for tasks in grunt.file.expand './node_modules/grunt-*/tasks'

    grunt.config.init

        clean:
            dist: ['./dist']

        coffee:
            files:
                expand: true
                cwd:    'src'
                src:    ['**/*.coffee', '!**/*.test.coffee']
                dest:   './dist'
                ext:    '.js'
                extDot: 'last'

        mochaTest:
            options:
                bail:     true
                color:    true
                reporter: 'dot'
                require: [
                    'coffee-script/register'
                    'test_helper.coffee'
                ]
                verbose: true
            src: '**/*.test.coffee'

        watch:
            coffee:
                files: ['**/*.coffee']
                tasks: ['build', 'test']

    # Composite Tasks ##############################################################################

    grunt.registerTask 'default', 'build the code and run tests',
        ['test', 'build']

    grunt.registerTask 'build', 'build the code',
        ['coffee']

    grunt.registerTask 'publish', 'build the code and publish to NPM',
        ['test', 'build', 'script:publish']

    grunt.registerTask 'test', 'run unit tests',
        ['mochaTest']

    # Script Tasks #####################################################################################################

    grunt.registerTask 'script:publish', 'publishes this package to NPM', ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/publish', opts:{stdio:'inherit'}, (error)-> done(error)
