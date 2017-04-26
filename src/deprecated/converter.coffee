#
# Crafting Guide Common - converter.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_       = require "../underscore"
Item    = require "../models/item"
Mod     = require "../models/mod"
ModPack = require "../models/mod_pack"
Recipe  = require "../models/recipe"
Stack   = require "../models/stack"

########################################################################################################################

module.exports = class Converter

    # Public Methods ###############################################################################

    convert: (id, displayName, oldModPack)->
        newModPack = new ModPack id:id, displayName:displayName

        oldModPack.eachMod (oldMod)=>
            oldMod.eachItem (oldItem)=>
                oldItem.slug.mod = oldMod.slug

        oldModPack.eachMod (oldMod)=>
            @_convertMod oldMod, newModPack

        oldModPack.eachMod (oldMod)=>
            oldMod.eachRecipe (oldRecipe)=>
                @_convertRecipe oldRecipe, newModPack

        return newModPack

    # Private Methods ##############################################################################

    _convertItem: (oldItem, newMod)->
        itemId = oldItem.slug.toString()
        newItem = new Item id:oldItem.slug.toString(), displayName:oldItem.name, mod:newMod

        if oldItem.isGatherable?
            newItem.isGatherable = oldItem.isGatherable

    _convertMod: (oldMod, newModPack)->
        modId = oldMod.slug.toString()
        version = oldMod.activeModVersion.version
        newMod = new Mod displayName:oldMod.name, id:modId, modPack:newModPack, version:version

        oldMod.eachItem (oldItem)=> @_convertItem oldItem, newMod

    _convertRecipe: (oldRecipe, newModPack)->
        oldOutputStack = oldRecipe.output[0]
        oldExtrasStacks = oldRecipe.output[1..]

        newOutputItem = newModPack.findItem oldOutputStack.itemSlug.toString()
        newOutputStack = new Stack item:newOutputItem, quantity:oldOutputStack.quantity
        newRecipe = new Recipe id:_.uniqueId("recipe-"), output:newOutputStack

        for extraStack in oldExtrasStacks
            extraItem = newModPack.findItem extraStack.itemSlug.toString()
            newRecipe.addExtra new Stack item:extraItem, quantity:extraStack.quantity

        for y in [0..2]
            for x in [0..2]
                oldStack = oldRecipe.getStackAtSlot (y * 3) + x
                continue unless oldStack?

                newInputItem = newModPack.findItem oldStack.itemSlug.toString()
                newRecipe.setInputAt x, y, new Stack item:newInputItem, quantity:oldStack.quantity

        for toolStack in oldRecipe.tools
            toolItem = newModPack.findItem toolStack.itemSlug.toString()
            newRecipe.addTool toolItem
