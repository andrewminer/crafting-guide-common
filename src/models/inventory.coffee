#
# Crafting Guide Common - inventory.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_          = require "../underscore"
Item       = require "./item"
Observable = require "../util/observable"
Stack      = require "./stack"

########################################################################################################################

module.exports = class Inventory extends Observable

    constructor: (inventory=null)->
        super

        @_id = _.uniqueId "inventory-"
        @_stacks = {}

        if inventory? then @merge inventory

    # Constants ####################################################################################

    # Events
    @::ADD    = "add"
    @::CLEAR  = "clear"
    @::CHANGE = "change"
    @::MERGE  = "merge"
    @::REMOVE = "remove"

    @::DELIMITERS =
        ITEM: "."
        STACK: ":"

    # Class Methods ################################################################################

    @fromUrlString: (urlString, modPack)->
        if not urlString then return new Inventory
        if not modPack? then throw new Error "modPack is required"

        result = new Inventory

        for stackPart in urlString.split @::DELIMITERS.STACK
            if stackPart.indexOf(@::DELIMITERS.ITEM) is -1
                quantity = 1
                qualifiedItemSlug = stackPart
            else
                [quantityText, qualifiedItemSlug] = stackPart.split @::DELIMITERS.ITEM
                quantity = parseInt quantityText
                if _.isNaN(quantityText) then throw new Errror "invalid quantity: #{quantityText}"

            [modId, itemSlug] = _.decomposeSlug qualifiedItemSlug
            item = modPack.findItemBySlug itemSlug, modId:modId
            if not item? then throw new Error "no item for slug: #{qualifiedItemSlug}"

            result.add item, quantity

        return result

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        isEmpty: # whether there is any amount of any item in this inventory
            get: -> (id for id, stack of @_stacks).length is 0

        stacks: # a map of item id to a stack describing the contents of this inventory
            get: -> return @_stacks
            set: -> throw new Error "stacks cannot be replaced"

    # Public Methods ###############################################################################

    add: (item, quantity)->
        return unless item?
        return if quantity is 0
        if not item.constructor is Item then throw new Error "item must be an Item"

        existingStack = @_stacks[item.id]
        if existingStack?
            if existingStack.quantity + quantity < 0 then throw new Error "cannot have a negative quantity"
            @muted -> existingStack.quantity += quantity
        else
            if quantity < 0 then throw new Error "cannot have a negative quantity"
            stack = new Stack item:item, quantity:quantity
            stack.on "change:quantity", this, "_onStackChanged"
            @_stacks[item.id] = stack

        if @_stacks[item.id].quantity is 0
            @_stacks[item.id].off Observable::ANY, this
            delete @_stacks[item.id]

        @trigger if quantity > 0 then @ADD else @REMOVE

    clear: ->
        @_stacks = {}
        @trigger @CLEAR

    contains: (item)->
        return @_stacks[item.id]?

    getQuantity: (item)->
        existingStack = @_stacks[item.id]
        return 0 unless existingStack?
        return existingStack.quantity

    merge: (inventory)->
        @muted =>
            for id, stack of inventory.stacks
                @add stack.item, stack.quantity
        @trigger @MERGE

    remove: (item, quantity=null)->
        quantity ?= @getQuantity item
        @add item, -1 * quantity

    # Object Overrides #############################################################################

    toDescription: ->
        allStacks = (stack for itemId, stack of @stacks)
        result = null

        if allStacks.length is 1
            result = allStacks[0].item.displayName
        else if allStacks.length > 1
            result = "#{allStacks[0].item.displayName} and #{allStacks.length - 1} more..."

        return result

    toUrlString: ->
        parts = []
        for itemId, stack of @stacks
            if stack.quantity is 1
                parts.push stack.item.qualifiedSlug
            else
                parts.push "#{stack.quantity}#{@DELIMITERS.ITEM}#{stack.item.qualifiedSlug}"

        return parts.join @DELIMITERS.STACK

    toString: (options={})->
        options.full ?= false

        if options.full
            result = []
            needsDelimiter = false

            stackList = (stack for itemId, stack of @_stacks)
            stackList.sort (a, b)->
                if a.item.displayName isnt b.item.displayName
                    return if a.item.displayName < b.item.displayName then -1 else +1
                return 0

            for stack in stackList
                if needsDelimiter then result.push ", "
                needsDelimiter = true

                result.push stack.quantity
                result.push " "
                result.push stack.item.displayName
            return result.join ""
        else
            return "Inventory<#{@_id}>@#{(id for id, item of @_stacks).length}"

    # Private Methods ##############################################################################

    _onStackChanged: ->
        @trigger @CHANGE

