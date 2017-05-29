#
# Crafting Guide Common - mod_pack_copyist.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

Item   = require "../models/item"
Mod    = require "../models/mod"
Recipe = require "../models/recipe"
Stack  = require "../models/stack"

########################################################################################################################

module.exports = class ModPackCopyist

    constructor: (sourceModPack)->
        @sourceModPack = sourceModPack

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        sourceModPack:
            get: -> return @_sourceModPack
            set: (sourceModPack)->
                if not sourceModPack? then throw new Error "sourceModPack is required"
                if @_sourceModPack? then throw new Error "sourceModPack cannot be reassigned"
                @_sourceModPack = sourceModPack

    # Methods ######################################################################################

    extractModInto: (modId, targetModPack, options={})->
        options.includeItems ?= true
        options.includeInputs ?= true
        options.includeMods ?= true
        options.includeRecipes ?= true
        options.includeTools ?= false

        mod = @_sourceModPack.mods[modId]
        if not mod? then throw new Error "#{modId} is not present in modPack #{@_sourceModPack.displayName}"

        @_cloneModInto mod, targetModPack, options
        return targetModPack

    # Private Methods ##############################################################################

    _cloneItemInto: (item, modPack, options={})->
        options.includeMods ?= false
        options.includeRecipes ?= false

        existing = modPack.findItem item.id
        return existing if existing?
        #console.log "_cloneItemInto: (#{item}, #{modPack}, #{JSON.stringify(options)})->"

        mod = modPack.mods[item.mod.id]
        if not mod?
            if options.includeMods
                mod = @_cloneModInto item.mod, modPack, options
            else
                return null

        clone = new Item id:item.id, displayName:item.displayName, isGatherable:item.isGatherable, mod:mod

        if options.includeRecipes
            for recipeId, recipe of item.recipesAsPrimary
                @_cloneRecipeInto recipe, modPack, options

        return clone

    _cloneModInto: (mod, modPack, options={})->
        options.includeItems ?= false

        existing = modPack.mods[mod.id]
        return existing if existing?
        #console.log "_cloneModInto: (#{mod}, #{modPack}, #{JSON.stringify(options)})->"

        clone = new Mod id:mod.id, displayName:mod.displayName, version:mod.version, modPack:modPack

        if options.includeItems
            for itemId, item of mod.items
                @_cloneItemInto item, modPack, options

        return clone

    _cloneRecipeInto: (recipe, modPack, options={})->
        options.includeInputs ?= true
        options.includeTools ?= false

        existing = modPack.findRecipe recipe.id
        if existing? then return existing
        #console.log "_cloneRecipeInto: (#{recipe}, #{modPack}, #{JSON.stringify(options)})->"

        output = @_cloneStackInto recipe.output, modPack, options
        if not output? then return null

        for x in [0...recipe.width]
            for y in [0...recipe.height]
                for z in [0...recipe.depth]
                    sourceInput = recipe.getInputAt x, y, z
                    continue unless sourceInput?

                    targetInput = @_cloneStackInto sourceInput, modPack, options
                    return null unless targetInput?

        for itemId, stack of recipe.extras
            item = @_cloneItemInto stack.item, modPack, options
            return null unless item?

        for itemId, item of recipe.tools
            item = modPack.findItem itemId
            if not item?
                if options.includeTools
                    item = @_cloneItemInto item, modPack, options
                else
                    return null

        clone = new Recipe id:recipe.id, output:output

        for x in [0...recipe.width]
            for y in [0...recipe.height]
                for z in [0...recipe.depth]
                    sourceInput = recipe.getInputAt x, y, z
                    continue unless sourceInput?

                    targetInput = @_cloneStackInto sourceInput, modPack, options
                    clone.setInputAt x, y, z, targetInput

        for itemId, stack of recipe.extras
            clone.addExtra @_cloneStackInto stack, modPack, options

        for itemId, item of recipe.tools
            clone.addTool @_cloneItemInto item, modPack, options

        return clone

    _cloneStackInto: (stack, modPack, options={})->
        item = modPack.findItem stack.item.id
        if not item?
            item = @_cloneItemInto stack.item, modPack, options

        clone = new Stack item:item, quantity:stack.quantity
        return clone
