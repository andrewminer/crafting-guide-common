# Crafting Guide Common - inventory.test.coffee
#
# Copyright (c) 2015 by Redwood Labs
# All rights reserved.
#

fixtures   = require "./fixtures"
Inventory  = require "./inventory"
Observable = require "../util/observable"

########################################################################################################################

describe "An Inventory", ->

    cake = inventory = inventory2 = modPack = observer = stick = sword = null

    beforeEach ->
        modPack = fixtures.createModPack id:"test", displayName:"test"
        mod     = fixtures.createMod modPack:modPack, id:"test", displayName:"test"
        cake    = fixtures.configureCake mod
        sword   = fixtures.configureIronSword mod
        stick   = fixtures.configureStick mod

        observer = onEvent:sinon.spy()

        inventory = new Inventory
        inventory.on Observable::ANY, observer, "onEvent"

    describe "by default", ->

        it "is empty", ->
            inventory.isEmpty.should.equal true
            inventory.stacks.should.eql {}

        it "doesn't contain any cake", ->
            inventory.contains(cake).should.equal false
            inventory.getQuantity(cake).should.equal 0

        it "has an empty URL string", ->
            inventory.toUrlString().should.equal ""

    describe "when created from a URL string", ->

        beforeEach ->
            observer.onEvent.reset()
            inventory = Inventory.fromUrlString "test__cake:3.test__iron_sword:4.stick", modPack

        it "has the right number of each item", ->
            inventory.getQuantity(cake).should.equal 1
            inventory.getQuantity(sword).should.equal 3
            inventory.getQuantity(stick).should.equal 4

        it "no events were fired", ->
            observer.onEvent.should.not.have.been.called

    describe "after adding a few items", ->

        beforeEach ->
            inventory.add cake, 2
            inventory.add sword, 3

        it "is no longer empty", ->
            inventory.isEmpty.should.equal false

        it "has two cakes", ->
            inventory.contains(cake).should.equal true
            inventory.getQuantity(cake).should.equal 2

        it "has a URL string with all the items", ->
            inventory.toUrlString().should.equal "2.test__cake:3.test__iron_sword"

        it "has fired an `add` event", ->
            observer.onEvent.should.have.been.calledWith "add", inventory
            observer.onEvent.should.have.been.calledTwice

        describe "then removing one of the cakes", ->

            beforeEach ->
                observer.onEvent.reset()
                inventory.remove cake, 1

            it "only has one cake left", ->
                inventory.getQuantity(cake).should.equal 1

            it "still has the same number of swords", ->
                inventory.getQuantity(sword).should.equal 3

            it "has a URL string with no quantity for cakes", ->
                inventory.toUrlString().should.equal "test__cake:3.test__iron_sword"

            it "a remove event was fired", ->
                observer.onEvent.should.have.been.calledWith "remove", inventory
                observer.onEvent.should.have.been.calledOnce

        describe "then merging in a different inventory", ->

            beforeEach ->
                observer.onEvent.reset()

                inventory2 = new Inventory
                inventory2.add cake, 5
                inventory2.add stick, 4
                inventory.merge inventory2

            it "now has the items from the other inventory", ->
                inventory.getQuantity(cake).should.equal 7
                inventory.getQuantity(stick).should.equal 4

            it "has the same number of unreleated items", ->
                inventory.getQuantity(sword).should.equal 3

            it "the updated URL string reflects the new items", ->
                inventory.toUrlString().should.equal "7.test__cake:3.test__iron_sword:4.test__stick"

            it "a merge event was fired", ->
                observer.onEvent.should.have.been.calledWith "merge", inventory
                observer.onEvent.should.have.been.calledOnce

        describe "then clearing the inventory", ->

            beforeEach -> inventory.clear()

            it "it's empty", ->
                inventory.isEmpty.should.equal true
                inventory.stacks.should.eql {}

            it "all of the items have been removed", ->
                inventory.contains(cake).should.equal false
                inventory.contains(sword).should.equal false
