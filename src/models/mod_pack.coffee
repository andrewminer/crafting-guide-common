#
# Crafting Guide Common - mod_pack.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

Observable = require "../util/observable"

########################################################################################################################

module.exports = class ModPack extends Observable

    constructor: (attributes={})->
        super

        @muted =>
            @id          = attributes.id
            @displayName = attributes.displayName

        @_mods = {}

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        displayName: # a string containing the user-displayable name of this ModPack
            get: -> return @_displayName
            set: (displayName)->
                if not displayName? then throw new Error "displayName is required"
                @triggerPropertyChange "displayName", @_displayName, displayName

        id: # a string which uniquely identifies this ModPack
            get: -> return @_id
            set: (id)->
                if not id? then throw new Error "id is required"
                if @_id is id then return
                if @_id? then throw new Error "id cannot be reassigned"
                @_id = id

        mods: # a hash of mod id to Mod containing all the mods which are part of this ModPack
            get: -> return @_mods
            set: -> throw new Error "mods cannot be replaced"

    # Public Methods ###############################################################################

    addMod: (mod)->
        if not mod? then return
        if @_mods[mod.id] is mod then return
        @_mods[mod.id] = mod
        mod.modPack = this
        @trigger "addMod"

    chooseRandomItem: ->
        mods = (mod for modId, mod of @mods)
        mod = mods[Math.floor(Math.random() * mods.length)]
        items = (item for itemId, item of mod.items)
        item = items[Math.floor(Math.random() * mods.length)]
        return item

    findItem: (itemId)->
        for modId, mod of @mods
            item = mod.items[itemId]
            return item if item?

        return null

    findItemBySlug: (itemSlug, options={})->
        options.modId ?= null

        for modId, mod of @mods
            continue if options.modId? and (options.modId isnt modId)

            for itemId, item of @mods[modId].items
                if item.slug is itemSlug
                    return item
        return null

    findRecipe: (recipeId)->
        for modId, mod of @mods
            for itemId, item of mod.items
                for currentRecipeId, recipe of item.recipesAsPrimary
                    if recipeId is currentRecipeId
                        return recipe
                for currentRecipeId, recipe of item.recipesAsExtra
                    if recipeId is currentRecipeId
                        return recipe

        return null

    # Object Overrides #############################################################################

    toString: ->
        return "ModPack:#{@displayName}<#{@id}>"
