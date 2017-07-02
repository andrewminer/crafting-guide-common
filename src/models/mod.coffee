#
# Crafting Guide Common - mod.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_          = require "../underscore"
Observable = require "../util/observable"

########################################################################################################################

module.exports = class Mod extends Observable

    @::DEFAULT_GROUP = "Other"

    constructor: (attributes={})->
        super

        @muted =>
            @author      = attributes.author
            @description = attributes.description
            @displayName = attributes.displayName
            @id          = attributes.id
            @isEnabled   = true
            @modPack     = attributes.modPack
            @version     = attributes.version

        @_items = {}
        @_itemGroups = {}
        @_tutorials = []

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        author:
            get: -> return @_author
            set: (author)->
                author = if _.isString(author) and (author.length > 0) then author else null
                @triggerPropertyChange "author", @_author, author

        description:
            get: -> return @_description
            set: (description)->
                description = if _.isString(description) and (description.length > 0) then description else null
                @triggerPropertyChange "description", @_description, description

        displayName:
            get: -> return @_displayName
            set: (displayName)->
                if not displayName? then throw new Error "displayName is required"
                @triggerPropertyChange "displayName", @_displayName, displayName

        id:
            get: -> return @_id
            set: (id)->
                if not id? then throw new Error "id is required"
                return if @_id is id
                if @_id? then throw new Error "id cannot be reassigned"
                @_id = id

        isEnabled:
            get: -> return @_isEnabled
            set: (isEnabled)-> @triggerPropertyChange "isEnabled", @_isEnabled, isEnabled

        itemGroups:
            get: -> return @_itemGroups
            set: -> throw new Error "itemGroups cannot be replaced"

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

        tutorials:
            get: -> return @_tutorials
            set: -> throw new Error "tutorials cannot be assigned"

        version:
            get: -> return @_version
            set: (version)->
                if not _.isString(version) then version = null
                @triggerPropertyChange "version", @_version, version

    # Public Methods ###############################################################################

    addItem: (item)->
        if not item? then return
        if @_items[item.id] is item then return
        @_items[item.id] = item
        item.mod = this

        groupName = item.groupName or @DEFAULT_GROUP
        groupList = @_itemGroups[groupName] ?= []
        groupList.push item

        @trigger "addItem"

    # Object Overrides #############################################################################

    toString: ->
        return "Mod:#{@displayName}<#{@id}>"
