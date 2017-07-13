#
# Crafting Guide Common - item_detail_json_parser.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_          = require "underscore"
ItemDetail = require "../../models/item_detail"
Link       = require "../../models/link"
ParserBase = require "./parser_base"
Video      = require "../../models/video"

########################################################################################################################

module.exports = class ItemDetailJsonParser extends ParserBase

    constructor: (item)->
        super

        @_item = item

    # ParserBase Overrides #########################################################################

    _parseObject: (obj)->
        super

        @_model = @_parseItemDetail obj
    
    # Private Methods ##############################################################################
    
    _parseItemDetail: (data)->
        detail = new ItemDetail item:@_item

        if data.description? then detail.description = data.description

        for linkData in (data.links or [])
            detail.addLink @_parseLink linkData

        for videoData in (data.videos or [])
            detail.addVideo @_parseVideo videoData

        return detail

    _parseLink: (linkData)->
        return new Link name:linkData.name, url:linkData.url

    _parseVideo: (videoData)->
        return new Video name:videoData.name, youTubeId:videoData.youTubeId

