#
# Crafting Guide Common - mod_pack_json_parser.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_          = require "underscore"
Item       = require "../../models/item"
Mod        = require "../../models/mod"
ModPack    = require "../../models/mod_pack"
ParserBase = require "./parser_base"
Recipe     = require "../../models/recipe"
Stack      = require "../../models/stack"

########################################################################################################################

module.exports = class ModPackJsonParser extends ParserBase

    # ParserBase Overrides #########################################################################

    _parseObject: (obj)->
        super

        @_parseModPack()
        @_parseMods()
        @_parseItems()
        @_parseRecipes()

    _reset: ->
        super

        @_items = []
        @_location = null
        @_model = null

    # Private Methods ##############################################################################

    _parseItems: ->
        return unless @_data.mods?

        for modData in @_data.mods
            continue unless modData.items?

            mod = @_model.mods[modData.id]
            for itemData, index in modData.items
                @_location = "<#{mod.id}>.items[#{index}]"
                if not itemData.id? then @_throwError "item requires an id"
                if not itemData.displayName? then @_throwError "item requires a displayName"

                item = new Item mod:mod, id:itemData.id, displayName:itemData.displayName, groupName:itemData.groupName
                item.isGatherable = itemData.gatherable if itemData.gatherable?
                @_items.push item

    _parseModPack: ->
        if not @_data? then @_throwError "there is no valid data"
        if not @_data.id? then @_throwError "modPack requires an id"
        if not @_data.displayName? then @_throwError "modPack requires a displayName"

        @_model = new ModPack id:@_data.id, displayName:@_data.displayName

    _parseMods: ->
        return unless @_data.mods?

        for modData, index in @_data.mods
            @_location = "mods[#{index}]"
            if not modData.id? then @_throwError "mod requires an id"
            if not modData.displayName? then @_throwError "mod requires a displayName"

            mod = new Mod modPack:@_model, id:modData.id, displayName:modData.displayName
            if modData.author? then mod.author = modData.author
            if modData.description? then mod.description = modData.description

    _parseRecipes: ->
        return unless @_data.mods?

        for modData in @_data.mods
            continue unless modData.items?

            mod = @_model.mods[modData.id]
            for itemData, index in modData.items
                continue unless itemData.recipes?

                item = mod.items[itemData.id]
                for recipeData, index in itemData.recipes
                    @_location = "<#{itemData.id}>.recipes[#{index}]"
                    if not recipeData.id? then @_throwError "recipe requires id"
                    if not recipeData.inputs? then @_throwError "recipe requires inputs"

                    quantity = @_parseInteger recipeData.quantity, 1
                    outputStack = new Stack item:item, quantity:quantity
                    recipe = new Recipe id:recipeData.id, output:outputStack

                    depth = @_parseInteger recipeData.depth, 1
                    height = @_parseInteger recipeData.height, 3
                    width = @_parseInteger recipeData.width, 3

                    index = 0
                    for x in [0...width]
                        for y in [0...height]
                            for z in [0...depth]
                                stack = @_parseStack recipeData.inputs[index]
                                if stack? then recipe.setInputAt x, y, z, stack
                                index++

                    if recipeData.extras
                        for stackData in recipeData.extras
                            recipe.addExtra @_parseStack stackData

                    if recipeData.tools
                        for index in recipeData.tools
                            toolItem = @_items[index]
                            if not toolItem? then @_throwError "there is no item #{index}"
                            recipe.addTool toolItem

    _parseStack: (stackData)->
        return null unless stackData?
        if _.isArray(stackData)
            if stackData.length isnt 2 then @_throwError "input stacks must have an item index and a quantity"
            index = stackData[0]
            quantity = stackData[1]
        else
            index = stackData
            quantity = 1

        item = @_items[index]
        if not item? then @_throwError "there is no item #{index}"

        return new Stack item:item, quantity:quantity

