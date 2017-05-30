#
# Crafting Guide Common - mod.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_ = require "../underscore"

########################################################################################################################

module.exports = class Mod

    constructor: (attributes={})->
        @description = attributes.description
        @displayName = attributes.displayName
        @id          = attributes.id
        @modPack     = attributes.modPack
        @version     = attributes.version

        @_items = {}

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        description:
            get: -> return @_description
            set: (description)->
                description = if _.isString(description) and (description.length > 0) then description else null
                @_description = description

        displayName:
            get: -> return @_displayName
            set: (displayName)->
                if not displayName? then throw new Error "displayName is required"
                return if @_displayName is displayName
                @_displayName = displayName

        id:
            get: -> return @_id
            set: (id)->
                if not id? then throw new Error "id is required"
                return if @_id is id
                if @_id? then throw new Error "id cannot be reassigned"
                @_id = id

        items:
            get: -> return @_items
            set: -> throw new Error "items cannot be replaced"

        modPack:
            get: -> return @_modPack
            set: (modPack)->
                if not modPack? then throw new Error "modPack is required"
                if @_modPack is modPack then return
                if @_modPack? then throw new Error "modPack cannot be reassigned"
                @_modPack = modPack
                @_modPack.addMod this

        version:
            get: -> return @_version
            set: (version)->
                if not _.isString(version) then version = null
                @_version = version

    # Public Methods ###############################################################################

    addItem: (item)->
        if not item? then return
        if @_items[item.id] is item then return
        @_items[item.id] = item
        item.mod = this

    # Object Overrides #############################################################################

    toString: ->
        return "Mod:#{@displayName}<#{@id}>"
