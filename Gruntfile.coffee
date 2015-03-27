###
# Crafting Guide - Gruntfile.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

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
                src:    '**/*.coffee'
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
                    './test/test_helper.coffee'
                ]
                verbose: true
            src: './test/**/*.test.coffee'

        watch:
            coffee:
                files: ['./src/**/*.coffee', './test/**/*.coffee']
                tasks: ['coffee', 'test']

    grunt.registerTask 'default', 'build'

    grunt.registerTask 'build', ['coffee']

    grunt.registerTask 'develop', ['clean', 'build', 'test', 'watch']

    grunt.registerTask 'test', ['mochaTest']
