#
# Crafting Guide Common - video.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_          = require "../underscore"
Observable = require "../util/observable"

########################################################################################################################

module.exports = class Video extends Observable

    constructor: (attributes={})->
        super

        @muted =>
            @id        = attributes.id or _.uniqueId "video-"
            @name      = attributes.name
            @youTubeId = attributes.youTubeId

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
                if not name? then throw new Error "name is required"
                if not name then throw new Error "name cannot be empty"
                @triggerPropertyChange "name", @_name, name

        youTubeId:
            get: -> return @_youTubeId
            set: (youTubeId)->
                if not youTubeId? then throw new Error "youTubeId is required"
                if not youTubeId then throw new Error "youTubeId cannot be empty"
                @triggerPropertyChange "youTubeId", @_youTubeId, youTubeId

    # Object Overrides #############################################################################
    
    toString: ->
        return "Video:#{@name}<#{@id}>"

