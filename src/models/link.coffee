#
# Crafting Guide Common - link.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_          = require "../underscore"
Observable = require "../util/observable"

########################################################################################################################

module.exports = class Link extends Observable

    constructor: (attributes={})->
        super

        @muted =>
            @id   = attributes.id or _.uniqueId "link-"
            @name = attributes.name
            @url  = attributes.url

    # Properties ###################################################################################
    
    Object.defineProperties @prototype,

        id:
            get: -> return @_id
            set: (id)->
                if not id? then throw new Error "id is required"
                if @_id? then throw new Error "id cannot be reassigned"
                @_id = id

        name:
            get: -> return @_name
            set: (name)->
                if not name then throw new Error "name is required"
                @triggerPropertyChange "name", @_name, name

        url:
            get: -> return @_url
            set: (url)->
                if not url then throw new Error "url is required"
                @triggerPropertyChange "url", @_url, url
