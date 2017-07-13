#
# Crafting Guide Common - mod_pack_store.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

c                 = require "../constants"
ModPackJsonParser = require "../parsing/json/mod_pack_json_parser"
StoreBase         = require "./store_base"

########################################################################################################################

module.exports = class ModPackStore extends StoreBase

    constructor: (options={})->
        @_parser = new ModPackJsonParser
        super options

    # StoreBase Overrides ##########################################################################

    _computePath: (id)->
        return c.url.modPackArchive modPackId:id
    
    _parse: (url, response)->
        return @_parser.parse response.body, url

