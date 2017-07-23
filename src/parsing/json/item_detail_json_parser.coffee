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
    
    _formatObject: (model)->
        super
        @_data = @_formatItemDetail model

    _parseObject: (obj)->
        super
        @_model = @_parseItemDetail obj
    
    # Private Methods ##############################################################################
    
    # Formatting Methods ###########################################################################
    
    _formatItemDetail: (itemDetail)->
        data = description:itemDetail.description

        if itemDetail.links.length > 0
            data.links = []
            for link in itemDetail.links
                data.links.push @_formatLink link

        if itemDetail.videos.length > 0
            data.videos = []
            for video in itemDetail.videos
                data.videos.push @_formatVideo video

        return data

    _formatLink: (link)->
        return name:link.name, url:link.url

    _formatVideo: (video)->
        return name:video.name, youTubeId:video.youTubeId
    
    # Parsing Methods ##############################################################################
    
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

