#
# Crafting Guide Common - logger.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_ = require 'underscore'

########################################################################################################################

module.exports = class Logger

    @TRACE   = {name:'TRACE  ', value:0, print:console.trace}
    @DEBUG   = {name:'DEBUG  ', value:1, print:console.debug}
    @VERBOSE = {name:'VERBOSE', value:2, print:console.log}
    @INFO    = {name:'INFO   ', value:3, print:console.info}
    @WARNING = {name:'WARNING', value:4, print:console.warn}
    @ERROR   = {name:'ERROR  ', value:5, print:console.error}
    @FATAL   = {name:'FATAL  ', value:6, print:console.error}
    @OFF     = {name:'OFF    ', value:7, print:(->)}

    ALL_LEVELS = [@TRACE, @DEBUG, @VERBOSE, @INFO, @WARNING, @ERROR, @FATAL, @OFF]

    constructor: (options={})->
        options.level ?= Logger.FATAL
        @formatText = options.format
        @formatText ?= "<%= timestamp %> | <%= level %> | <%= indent %><%= message %>"
        @level      = @_parseLevel options

        @_format = _.template @formatText
        @_indent = ''

    # Public Methods ###############################################################################

    indent: ->
        @_indent += '    '

    log: (level, message)->
        return unless level.value >= @level.value
        message = if _.isFunction message then "#{message()}" else "#{message}"
        message ?= ''

        entry = {timestamp:new Date(), level:level, message:message, indent:@_indent}
        entry.level ?= @level

        lines = @_formatEntry entry
        entry.level.print ?= console.log
        entry.level.print.call console, line for line in lines

    outdent: ->
        @_indent = @_indent[0...@_indent.length - 4]

    doAtLevel: (level, callback)->
        priorLevel = @level
        @level = if _.isString(level) then Logger[level.toUpperCase()] else level
        try
            @log level, ''
            callback()
        finally
            @level = priorLevel

    # Log Methods ##################################################################################

    trace: (message)-> @log Logger.TRACE, message

    debug: (message)-> @log Logger.DEBUG, message

    verbose: (message)-> @log Logger.VERBOSE, message

    info: (message)-> @log Logger.INFO, message

    warning: (message)-> @log Logger.WARNING, message

    error: (message)->
        message = "#{message.stack}" if message.stack?
        @log Logger.ERROR, message

    fatal: (message)-> @log Logger.FATAL, message

    # Private Methods ##############################################################################

    _formatEntry: (entry, lines=[])->
        message = entry.message.replace /\\n/g, '\n'
        for line in message.split '\n'
            result = []
            result.push @_format
                timestamp: "#{entry.timestamp.toISOString()}"
                level:     entry.level.name
                message:   line
                indent:    entry.indent
            lines.push result.join ''
        return lines

    _parseLevel: (options)->
        return Logger.FATAL unless _(options).has 'level'
        level = options.level

        if not level?
            candidates = []
        else if _.isString level
            candidates = (l for l in ALL_LEVELS when l.name.trim().toLowerCase() is level.trim().toLowerCase())
        else if _.isNumber level
            candidates = (l for l in ALL_LEVELS when l.value is level)
        else if level?
            candidates = (l for l in ALL_LEVELS when l is level)

        throw new Error "invalid level: #{level}" unless candidates.length > 0
        return candidates[0]
