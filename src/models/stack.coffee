#
# Crafting Guide Common - stack.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

Item       = require "./item"
Observable = require "../util/observable"

########################################################################################################################

module.exports = class Stack extends Observable

    constructor: (attributes={})->
        super

        @muted =>
            @item = attributes.item
            @quantity = attributes.quantity

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        item:
            get: -> return @_item
            set: (item)->
                if not item? then throw new Error "item is required"
                if not item.constructor is Item then throw new Error "item must be a Item"
                if @_item is item then return
                if @_item? then throw new Error "item cannot be reassigned"
                @_item = item

        modPack:
            get: -> return @_item.modPack
            set: -> throw new Error "modPack cannot be replaced"

        quantity:
            get: -> return @_quantity
            set: (quantity)->
                quantity = parseInt "#{quantity}"
                quantity = if Number.isNaN(quantity) then 1 else Math.max(0, quantity)
                @triggerPropertyChange "quantity", @_quantity, quantity

    # Object Overrides #############################################################################

    toString: ->
        return "Stack:#{@item}×#{@quantity}"
