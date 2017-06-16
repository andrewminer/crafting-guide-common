#
# Crafting Guide Common - item.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_          = require "../underscore"
Observable = require "../util/observable"

########################################################################################################################

module.exports = class Item extends Observable

    @::DEFAULT_GROUP_NAME = "Other"

    constructor: (attributes={})->
        super

        @muted =>
            @id           = attributes.id
            @displayName  = attributes.displayName
            @groupName    = attributes.groupName
            @isGatherable = attributes.isGatherable
            @mod          = attributes.mod

        @_hasPrimaryRecipe = false
        @_recipesAsPrimary = {}
        @_recipesAsExtra = {}

    # Property Methods #############################################################################

    Object.defineProperties @prototype,

        displayName: # a string containing the user-facing name of this item
            get: -> return @_displayName
            set: (displayName)->
                if not displayName? then throw new Error "displayName is required"
                @_displayName = displayName
                @_slug = null
                @_qualifiedSlug = null
                @trigger "change", "displayName"

        firstRecipe: # the first Recipe returned by iterating the `recipes` property
            get: ->
                recipeList = (recipe for id, recipe of @recipes)
                return null unless recipeList.length > 0
                return recipeList[0]
            set: -> throw new Error "firstRecipe cannot be assigned"

        groupName: # a string specifying which display group this item belongs to
            get: -> return @_groupName
            set: (groupName)->
                groupName = if groupName then groupName else @DEFAULT_GROUP_NAME
                if @_groupName? then throw new Error "groupName cannot be reassigned"
                @_groupName = groupName
                @trigger "change", "groupName"

        id: # a string containing a unique identifier for this item
            get: -> return @_id
            set: (id)->
                if not id? then throw new Error "id is required"
                return if @_id is id
                if @_id? then throw new Error "id cannot be reassigned"
                @_id = id

        isGatherable: # whether this item can be gathered directly without needing to be crafted
            get: ->
                return @_isGatherable
            set: (isGatherable)->
                @_isGatherable = !!isGatherable
                @trigger "change", "isGatherable"

        isMultiblock: # whether this item is made as a 3D construction from multiple blocks
            get: ->
                for recipeId, recipe of @recipes
                    return false if recipe.depth is 1
                return true
            set: -> throw new Error "isMultiblock cannot be assigned"

        mod: # the Mod which adds this item to the game
            get: -> return @_mod
            set: (mod)->
                if not mod? then throw new Error "mod is required"
                if @_mod is mod then return
                if @_mod? then throw new Error "mod cannot be reassigned"
                @_mod = mod
                @_mod.addItem this

        modPack: # the ModPack containing this item
            get: -> return @_mod.modPack
            set: -> throw new Error "modPack cannot be assigned"

        qualifiedSlug: # a string of the form: <mod.id>__<slug>
            get: -> return @_qualifiedSlug ?= "#{@mod.id}__#{@slug}"
            set: -> throw new Error "qualifiedSlug cannot be assigned"

        recipes: # a hash of recipeId to Recipe containing `recipesAsPrimary` if not empty or else `recipesAsExtra`
            get: -> return if @_hasPrimaryRecipe then @_recipesAsPrimary else @_recipesAsExtra
            set: -> throw new Error "recipes cannot be assigned"

        recipesAsPrimary: # a hash of recipeId to Recipe where this item is the primary output
            get: -> return @_recipesAsPrimary
            set: -> throw new Error "recipes cannot be assigned"

        recipesAsExtra: # a hash of recipeId to Recipe where this item is an extra output
            get: -> return @_recipesAsExtra
            set: -> throw new Error "recipesAsExtra cannot be assigned"

        slug:
            get: -> return @_slug ?= _.slugify @displayName
            set: -> throw new Error "slug cannot be assigned"

    # Public Recipes ###############################################################################

    addRecipe: (recipe)->
        if recipe.output.item is this
            @_recipesAsPrimary[recipe.id] = recipe
            @_hasPrimaryRecipe = true
        else if recipe.extras[this.id]?.item is this
            @_recipesAsExtra[recipe.id] = recipe
        else
            throw new Error "recipe<#{recipe.id}> does not produce this item<#{@id}>"

        @trigger "addRecipe"

    # Object Overrides #############################################################################

    toString: ->
        return "Item:#{@displayName}<#{@id}>"
