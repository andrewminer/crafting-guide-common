#
# Crafting Guide Common - item_detail_store.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_                    = require "../underscore"
c                    = require "../constants"
ItemDetailJsonParser = require "../parsing/json/item_detail_json_parser"
StoreBase            = require "./store_base"

########################################################################################################################

module.exports = class ItemDetailStore extends StoreBase

    constructor: (options={})->
        @_parser = new ItemDetailJsonParser
        super options

    # Public Methods ###############################################################################
    
    loadDetailFor: (item)->
        return @load item.id, item

    # StoreBase Overrides ##########################################################################

    _computePath: (id, item)->
        return c.url.itemData modId:item.mod.id, itemSlug:item.slug
    
    _parse: (url, response, item)->
        parser = new ItemDetailJsonParser item
        return parser.parse response.body, url

