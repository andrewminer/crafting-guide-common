#
# Crafting Guide Common - mod_pack_copyist.test.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_              = require "../underscore"
fixtures       = require "../models/fixtures"
ModPackCopyist = require "./mod_pack_copyist"
util           = require "util"

########################################################################################################################

describe "ModPackCopyist", ->

    beforeEach ->
        @source = fixtures.createModPack id:"source", displayName:"Source"
        @target = fixtures.createModPack id:"target", displayName:"Target"

        baseMod = fixtures.createMod id:"base", displayName:"Base", modPack:@source
        foodMod = fixtures.createMod id:"food", displayName:"Food", modPack:@source
        toolMod = fixtures.createMod id:"tool", displayName:"Tool", modPack:@source

        fixtures.configureCraftingTable baseMod
        fixtures.configureFurnace baseMod
        fixtures.configureIronBlock baseMod
        fixtures.configureObsidian baseMod
        fixtures.configureRedstone baseMod
        fixtures.configureStick baseMod

        fixtures.configureBucket toolMod
        fixtures.configureIronSword toolMod
        fixtures.configureIronShovel toolMod
        fixtures.configureSaw toolMod

        fixtures.configureCake foodMod

        @copyist = new ModPackCopyist @source

    describe "when extracting a base mod", ->

        beforeEach ->
            @copyist.extractModInto "base", @target, includeMods:false

        it "copies over only the base mod", ->
            (id for id, mod of @target.mods).should.eql ["base"]

        it "copies over only the items in the base mod", ->
            sourceIds = (id for id, item of @source.mods.base.items).sort()
            targetIds = (id for id, item of @target.mods.base.items).sort()
            targetIds.should.eql sourceIds

        it "creates new instances of each item", ->
            @source.mods.base.items.furnace.displayName = "Not a furnace"
            @target.mods.base.items.furnace.displayName.should.equal "Furnace"

        it "copies over the recipes for the items", ->
            (id for id, recipe of @source.mods.base.items.furnace.recipes).length.should.equal 1
            recipe = @source.mods.base.items.furnace.firstRecipe
            [recipe.width, recipe.height, recipe.depth].should.eql [3, 3, 1]
            _.uniq((s.toString() for s in _.compact(recipe.getInputs()))).should.eql [
                "Stack:Item:Cobblestone<cobblestone>×1"
            ]
            (id for id, item of recipe.tools).should.eql ["crafting_table"]

    describe "when extracting an extension mod", ->

        beforeEach ->
            @copyist.extractModInto "tool", @target

        it "copies over both the extension and base mods", ->
            (id for id, mod of @target.mods).sort().should.eql ["base", "tool"]

        it "copies all items from the extension mod along with those needed from the base"

        it "copies over recipes for the new items"

        it "copies over new recipes for base items from the extension mod"
