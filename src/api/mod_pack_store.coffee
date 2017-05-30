#
# Crafting Guide Common - mod_pack_store.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_                 = require "../underscore"
c                 = require "../constants"
ModPackJsonParser = require "../parsing/json/mod_pack_json_parser"

########################################################################################################################

module.exports = class ModPackStore

    constructor: (http, baseUrl)->
        @_loading  = {}
        @_modPacks = {}
        @_parser   = new ModPackJsonParser

        @baseUrl = baseUrl
        @http    = http

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

    get: (modPackId)->
        return @_modPacks[modPackId]

    load: (modPackId)->
        if @_loading[modPackId]? then return @_loading[modPackId]

        url = @baseUrl + c.url.modPackArchiveJS modPackId:modPackId
        @_loading[modPackId] = @http.get url
            .then (response)=>
                if response.statusCode isnt 200 then throw new Error "#{response.statusCode} #{response.body}"
                @_modPacks[modPackId] = @_parser.parse response.body, url
