#
# Crafting Guide Common - parser_base.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_ = require "underscore"

########################################################################################################################

module.exports = class ParserBase

    constructor: ->
        @_reset()

    # Public Methods ###############################################################################

    parse: (arg, fileName=null)->
        @_reset()
        @_fileName = fileName

        if _.isString arg
            @_parseText arg
        else
            @_parseObject arg

        return @_model

    format: (model, options={})->
        @_reset()
        @_formatObject model
        @_data ?= {}
        return JSON.stringify @_data, options.replacer, options.indent
    
    # Overridable Methods ##########################################################################
    
    _formatObject: (model)->
        @_model = model

        # Subclasses may override this method to provide their own formatting functionality. They should begin by
        # calling this implementation, and then do their own work. The result should be an object which can be passsed
        # to JSON.stringify placed in the @_data instance variable.
    
    _parseObject: (obj)->
        @_data = obj

        # Subclasses should override this method to provide their own parsing functionality.  They should begin by
        # calling this implementation, and then do their own work.  The result should be placed in the @_model instance
        # variable.

    _reset: ->
        @_data = null
        @_fileName = null

        # Subclasses should override this to clear out any cached data they may have kept. They must be sure to call
        # this implementation.

    # Protected Methods ############################################################################

    _parseInteger: (text, defaultValue)->
        result = parseInt "#{text}"
        result = if Number.isNaN result then defaultValue else result
        return result

    _throwError: (message, cause=null)->
        if @_location? then message = "#{@_location}: #{message}"
        if @_fileName? and @_location? then message = "@#{message}"
        if @_fileName? then message = "#{@_fileName}#{message}"
        if cause? then message = "#{message}: #{cause}"

        error = new Error message
        error.cause = cause if cause?
        error.fileName = @_fileName if @_fileName?
        error.location = @_location if @_location?

        throw error

    # Private Methods ##############################################################################

    _parseText: (text)->
        try
            obj = JSON.parse text
        catch error
            @_throwError "could not parse JSON: #{error}"

        @_parseObject obj

