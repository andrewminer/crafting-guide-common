#
# Crafting Guide - crafting_plan_step.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

_         = require "../underscore"
Inventory = require "../models/inventory"

########################################################################################################################

module.exports = class CraftingPlanStep

    constructor: (recipe, count=1)->
        @_id    = _.uniqueId "crafting-plan-step-"
        @recipe = recipe
        @count  = count
        @number = 0

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        inputInventory:
            get: -> return @_inputInventory ?= @_computeInputInventory()
            set: -> throw new Error "inputInventory cannot be assigned"

        number:
            get: -> return @_number
            set: (number)->
                if not _.isNumber(number) then throw new Error "number must be a number"
                @_number = number

        recipe:
            get: -> return @_recipe
            set: (recipe)->
                if not recipe? then throw new Error 'recipe is required'
                if @_recipe is recipe then return
                if @_recipe? then throw new Error 'recipe cannot be reassigned'
                @_recipe = recipe

        count:
            get: -> return @_count
            set: (count)->
                count = parseInt "#{count}"
                count = if Number.isNaN(count) then 0 else Math.max 0, count
                @_count = count

    # Public Methods ###############################################################################

    completeInto: (targetInventory)->
        targetInventory.add @recipe.output.item, @recipe.output.quantity * @count
        for itemId, stack of @recipe.extras
            targetInventory.add stack.item, stack.quantity * @count

    # Object Overrides #############################################################################

    toString: ->
        return "CraftingPlanStep:#{@_recipe}×#{@_count}<#{@_id}>"

    # Private Methods ##############################################################################

    _computeInputInventory: ->
        result = new Inventory

        for itemId, item of @recipe.inputs
            quantity = @recipe.computeQuantityRequired(item) * @count
            result.add item, quantity

        return result
