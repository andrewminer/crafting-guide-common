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

    constructor: (http)->
        @_loading  = {}
        @_modPacks = {}
        @_parser   = new ModPackJsonParser

        @http = http

    # Properties ###################################################################################

    Object.defineProperties @prototype,
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

        url = c.url.modPackArchiveJS modPackId:modPackId
        @_loading[modPackId] = @http.get url
            .then (jsonText)=>
                @_modPacks[modPackId] = @_parser.parse jsonText, url
            .catch (error)->
                logger.error "failed to load mod pack #{modPackId}: #{error}"
                throw error
