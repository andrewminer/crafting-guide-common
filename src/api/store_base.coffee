#
# Crafting Guide Common - store_base.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_ = require "../underscore"
c = require "../constants"

########################################################################################################################

module.exports = class StoreBase

    constructor: (options={})->
        @_loading  = {}
        @_objects = {}

        @baseUrl = options.baseUrl
        @http    = options.http

    # Properties ###################################################################################

    Object.defineProperties @prototype,
        baseUrl:
            get: -> return @_baseUrl
            set: (baseUrl)->
                if not _.isString(baseUrl) then throw new Error "baseUrl must be a string"
                @_baseUrl = baseUrl

        http:
            get: -> return @_http
            set: (http)->
                if not http? then throw new Error "http is required"
                if not _.isFunction(http.get) then throw new Error "http must support GET"
                @_http = http

    # Public Methods ###############################################################################

    get: (id)->
        return @_objects[id]

    load: (id, context={})->
        if @_loading[id]? then return @_loading[id]

        url = @baseUrl + @_computePath id, context
        @_loading[id] = @http.get url
            .then (response)=>
                if response.statusCode isnt 200 then throw new Error "#{response.statusCode} #{response.body}"
                @_objects[id] = @_parse url, response, context

    # Overridable Methods ##########################################################################
    
    _computePath: (id)->
        throw new Error "#{@constructor.name} must override _computePath"

    _parse: (url, response, context={})->
        throw new Error "#{@constructor.name} must override _parse"

