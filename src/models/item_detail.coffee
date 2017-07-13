#
# Crafting Guide Common - item_detail.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_          = require "../underscore"
Link       = require "./link"
Observable = require "../util/observable"
Video      = require "./video"

########################################################################################################################

module.exports = class ItemDetail extends Observable

    constructor: (attributes={})->
        super

        @_links = []
        @_videos = []

        @muted =>
            @item = attributes.item
            @description = attributes.description

            for link in (attributes.links or [])
                @addLink link

            for video in (attributes.videos or [])
                @addVideo video

    # Class Properties #############################################################################

    @::ADD_LINK = "add-link"
    @::ADD_VIDEO = "add-video"

    # Properties ###################################################################################
    
    Object.defineProperties @prototype,

        description:
            get: -> return @_description
            set: (description)->
                description ?= ""
                @triggerPropertyChange "description", @_description, description

        item:
            get: -> return @_item
            set: (item)->
                if @_item is item then return
                if not item? then throw new Error "item is required"
                if @_item? then throw new Error "item cannot be reassigned"
                @_item = item
                @_item.detail = this

        links:
            get: -> return @_links[..]
            set: -> throw new Error "links cannot be assigned"

        videos:
            get: -> return @_videos[..]
            set: -> throw new Error "videos cannot be assigned"

    # Methods ######################################################################################
    
    addLink: (link)->
        if link?.constructor isnt Link then throw new Error "link must be a Link"
        @_links.push link
        @trigger @ADD_LINK
    
    addVideo: (video)->
        if video?.constructor isnt Video then throw new Error "video must be a Video"
        @_videos.push video
        @trigger @ADD_VIDEO

