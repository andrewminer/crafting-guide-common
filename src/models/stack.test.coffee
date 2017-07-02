# Crafting Guide Common - inventory.test.coffee
#
# Copyright (c) 2015 by Redwood Labs
# All rights reserved.
#

fixtures   = require "./fixtures"
Stack      = require "./stack"
Observable = require "../util/observable"

########################################################################################################################

describe "A Stack", ->

    modPack = observer = stack = sword = null

    beforeEach ->
        modPack = fixtures.createModPack id:"test", displayName:"test"
        mod     = fixtures.createMod modPack:modPack, id:"test", displayName:"test"
        sword   = fixtures.configureIronSword mod

        observer = onEvent:sinon.spy()

    describe "created with just an item", ->

        beforeEach ->
            stack = new Stack item:sword
            stack.on Observable::ANY, observer, "onEvent"

        it "has the expected item", ->
            stack.item.should.equal sword

        it "has exactly 1 of them", ->
            stack.quantity.should.equal 1

        it "no events are fired", ->
            observer.onEvent.should.not.have.been.called

    describe "created with an item and an explicit quantity", ->

        beforeEach ->
            stack = new Stack item:sword, quantity:12
            stack.on Observable::ANY, observer, "onEvent"

        it "has the expected item", ->
            stack.item.should.equal sword

        it "has exactly 12 of them", ->
            stack.quantity.should.equal 12

        it "no events are fired", ->
            observer.onEvent.should.not.have.been.called

        describe "when the quantity changes", ->

            beforeEach -> stack.quantity = 11

            it "the stack's quantity is changed", ->
                stack.quantity.should.equal 11

            it "should fire a set of change events", ->
                observer.onEvent.should.have.been.calledWith "change:quantity", stack, 12, 11
                observer.onEvent.should.have.been.calledWith "change", stack
