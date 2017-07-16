#
# Crafting Guide Common - converter.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_                    = require "../underscore"
Item                 = require "../models/item"
Logger               = require "../util/logger"
Mod                  = require "../models/mod"
ModPack              = require "../models/mod_pack"
ModPackJsonFormatter = require "../parsing/json/mod_pack_json_formatter"
Recipe               = require "../models/recipe"
Stack                = require "../models/stack"

########################################################################################################################

if not global.logger?
    global.logger ?= new Logger

########################################################################################################################

module.exports = class Converter

    # Public Methods ###############################################################################

    convert: (id, displayName, oldModPack)->
        formatter = new ModPackJsonFormatter

        newModPack = new ModPack id:id, displayName:displayName

        oldModPack.eachMod (oldMod)=>
            oldMod.eachItem (oldItem)=>
                oldItem.slug.mod = oldMod.slug

        oldModPack.eachMod (oldMod)=>
            @_convertMod oldMod, newModPack

        oldModPack.eachMod (oldMod)=>
            oldMod.eachRecipe (oldRecipe)=>
                @_convertRecipe oldRecipe, newModPack

        oldModPack.eachMod (oldMod)=>
            oldMod.eachItem (oldItem)=>
                @_convertMultiblock oldItem, newModPack

        return newModPack

    # Private Methods ##############################################################################

    _convertItem: (oldItem, newMod)->
        itemId = oldItem.slug.toString()
        newItem = new Item id:oldItem.slug.toString(), displayName:oldItem.name, groupName:oldItem.group, mod:newMod

        if oldItem.isGatherable?
            newItem.isGatherable = oldItem.isGatherable

    _convertMod: (oldMod, newModPack)->
        newMod = new Mod
            author:      oldMod.author
            description: oldMod.description
            displayName: oldMod.name
            id:          oldMod.slug.toString()
            modPack:     newModPack
            version:     oldMod.activeModVersion.version

        oldMod.eachItem (oldItem)=> @_convertItem oldItem, newMod

    _convertMultiblock: (oldItem, newModPack)->
        return unless oldItem.multiblock?
        oldMultiblock = oldItem.multiblock
        oldModPack = oldItem.modVersion.mod.modPack

        newItem = newModPack.findItem oldItem.slug.toString()
        if not newItem?
            throw new Error "Could not find #{newItem.slug} as output for a new recipe"

        newOutputStack = new Stack item:newItem, quantity:1
        recipe = new Recipe id:_.uniqueId("recipe-"), output:newOutputStack

        for x in [0..oldMultiblock.width]
            for y in [0..oldMultiblock.height]
                for z in [0..oldMultiblock.depth]
                    oldOutputStack = oldMultiblock.getStackAt x, y, z
                    continue unless oldOutputStack?

                    oldOutputItem = oldModPack.findItem oldOutputStack.itemSlug
                    if not oldOutputItem?
                        throw new Error "Could not find old item for #{oldOutputStack.itemSlug} for a new recipe"

                    newItem = newModPack.findItem oldOutputItem.slug.toString()
                    if not newItem?
                        throw new Error "Could not find new item for #{oldOutputStack.itemSlug} for a new recipe"

                    newStack = new Stack item:newItem, quantity:oldOutputStack.quantity
                    recipe.setInputAt x, y, z, newStack

    _convertRecipe: (oldRecipe, newModPack)->
        oldModPack = oldRecipe.modVersion.mod.modPack

        oldOutputStack = oldRecipe.output[0]
        oldOutputItem = oldModPack.findItem oldOutputStack.itemSlug
        if not oldOutputItem?
            throw new Error "Could not find old item for #{oldOutputStack.itemSlug} for a new recipe"

        oldExtrasStacks = oldRecipe.output[1..]

        newOutputItem = newModPack.findItem oldOutputItem.slug.toString()
        if not newOutputItem?
            throw new Error "Could not find #{oldOutputItem.slug} as output for a new recipe"

        newOutputStack = new Stack item:newOutputItem, quantity:oldOutputStack.quantity
        newRecipe = new Recipe id:_.uniqueId("recipe-"), output:newOutputStack

        for extraStack in oldExtrasStacks
            oldExtraItem = oldModPack.findItem extraStack.itemSlug
            if not oldExtraItem?
                throw new Error "Could not find an old item for #{extraStack.itemSlug}
                    as extra for #{newRecipe.output.item.id}"

            extraItem = newModPack.findItem oldExtraItem.slug.toString()
            if not extraItem?
                throw new Error "Could not find #{extraStack.itemSlug} as extra for #{newRecipe.output.item.id}"
            newRecipe.addExtra new Stack item:extraItem, quantity:extraStack.quantity

        for y in [0..2]
            for x in [0..2]
                oldStack = oldRecipe.getStackAtSlot (y * 3) + x
                continue unless oldStack?

                oldItem = oldModPack.findItem oldStack.itemSlug
                if not oldItem?
                    throw new Error "Could not find an old item for #{oldStack.itemSlug}
                        as input for #{newRecipe.output.item.id}"

                newInputItem = newModPack.findItem oldItem.slug.toString()
                if not newInputItem?
                    throw new Error "Could not find a new item for #{oldItem.slug}
                        as input for #{newRecipe.output.item.id}"

                newRecipe.setInputAt x, y, new Stack item:newInputItem, quantity:oldStack.quantity

        for toolStack in oldRecipe.tools
            oldToolItem = oldModPack.findItem toolStack.itemSlug
            if not oldToolItem?
                throw new Error "Could not find an old item for #{toolStack.itemSlug}
                    as a tool for #{newRecipe.output.item.id}"

            toolItem = newModPack.findItem oldToolItem.slug.toString()
            if not toolItem?
                throw new Error "Could not find #{toolStack.itemSlug} as tool for #{newRecipe.output.item.id}"
            newRecipe.addTool toolItem
