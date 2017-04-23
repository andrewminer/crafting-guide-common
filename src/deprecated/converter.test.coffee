#
# Crafting Guide Common - converter.test.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_                    = require "../underscore"
Converter            = require "./converter"
fixtures             = require "./fixtures"
ModPackJsonFormatter = require "../parsing/json/mod_pack_json_formatter"

########################################################################################################################

describe.only "Converter", ->

    beforeEach ->
        @oldModPack = fixtures.createModPack id:"alpha", displayName:"ALPHA"

        @converter = new Converter
        @convert = => @newModPack = @converter.convert "alpha-new", "ALPHA NEW", @oldModPack

        @formatter = new ModPackJsonFormatter
        @dump = (modPack)=>
            console.log @oldModPack.toString()
            console.log @formatter.format(@newModPack)

    describe "an empty modpack", ->

        beforeEach -> @convert()

        it "has the new name and id", ->
            @newModPack.id.should.equal "alpha-new"
            @newModPack.displayName.should.equal "ALPHA NEW"

        it "doesn't have any mods", ->
            @newModPack.mods.should.eql {}

    describe "a modpack containing only an empty mod", ->

        beforeEach ->
            @oldMod = fixtures.createMod modPack:@oldModPack, slug:"bravo", name:"Bravo"
            @oldModVersion = fixtures.createModVersion mod:@oldMod, version:"1.0"
            @convert()
            @newMod = @newModPack.mods["bravo"]

        it "has a single mod based upon the old mod", ->
            (id for id, mod of @newModPack.mods).should.eql ["bravo"]
            @newMod.id.should.equal "bravo"
            @newMod.displayName.should.equal "Bravo"

        it "the new mod's version matches the active version from the old modpack", ->
            @newMod.version.should.equal "1.0"

        it "the new mod has no items", ->
            @newMod.items.should.eql {}

    describe "a modpack containing a few gatherable items in a single mod", ->

        beforeEach ->
            @oldMod = fixtures.createMod modPack:@oldModPack, slug:"minecraft", name:"Minecraft"
            @oldModVersion = fixtures.createModVersion mod:@oldMod, version:"1.7.10"
            fixtures.configureCoal @oldModVersion
            fixtures.configureCobblestone @oldModVersion
            fixtures.configureRedstone @oldModVersion
            @convert()
            @newMod = @newModPack.mods["minecraft"]

        it "contains the expected items", ->
            (id for id, item of @newModPack.mods["minecraft"].items).sort().should.eql [
                "minecraft__coal", "minecraft__cobblestone", "minecraft__redstone_dust"
            ]

        it "the items get the correct names", ->
            (item.displayName for id, item of @newModPack.mods["minecraft"].items).sort().should.eql [
                "Coal", "Cobblestone", "Redstone"
            ]

        it "the items don't have any recipes", ->
            _.uniq(item.firstRecipe for id, item of @newModPack.mods["minecraft"].items).should.eql [null]

        it "item ids from unqualified slugs become qualified", ->
            @newModPack.mods["minecraft"].items["minecraft__coal"].displayName.should.equal "Coal"

    describe "a modpack containing a few gatherable items spread across multiple mods", ->

        beforeEach ->
            @oldModA = fixtures.createMod modPack:@oldModPack, slug:"alpha", name:"Alpha"
            @oldModVersionA = fixtures.createModVersion mod:@oldModA, version:"1.0"
            fixtures.configureCoal @oldModVersionA
            fixtures.configureCobblestone @oldModVersionA

            @oldModB = fixtures.createMod modPack:@oldModPack, slug:"bravo", name:"Bravo"
            @oldModVersionB = fixtures.createModVersion mod:@oldModB, version:"1.1"
            fixtures.configureOakWood @oldModVersionB
            fixtures.configureWheat @oldModVersionB

            @convert()

        it "the modpack has both mods", ->
            (mod.displayName for id, mod of @newModPack.mods).should.eql ["Alpha", "Bravo"]

        it "each mod has the items it should", ->
            (id for id, item of @newModPack.mods["alpha"].items).should.eql [
                "alpha__coal", "alpha__cobblestone"
            ]
            (id for id, item of @newModPack.mods["bravo"].items).should.eql [
                "bravo__oak_wood", "bravo__wheat"
            ]

    describe "a modpack containing a single basic recipe", ->

        beforeEach ->
            @oldMod = fixtures.createMod modPack:@oldModPack, slug:"minecraft", name:"Minecraft"
            @oldModVersion = fixtures.createModVersion mod:@oldMod, version:"1.7.10"
            fixtures.configureOakPlanks @oldModVersion
            @convert()
            @recipe = @newModPack.mods["minecraft"].items["minecraft__oak_planks"].firstRecipe


        it "the recipe has the correct inputs", ->
            ((@recipe.getInputAt(x, y)?.item.id for x in [0..2]) for y in [0..2]).should.eql [
                ["minecraft__oak_wood", undefined, undefined]
                [undefined, undefined, undefined]
                [undefined, undefined, undefined]
            ]

        it "the recipe should have computed the correct dimensions", ->
            @recipe.height.should.equal 1
            @recipe.width.should.equal 1
            @recipe.depth.should.equal 1

        it "the recipe has the correct output", ->
            @recipe.output.item.id.should.equal "minecraft__oak_planks"
            @recipe.output.quantity.should.equal 4

        it "the recipe requires no tools", ->
            @recipe.needsTools.should.equal false

        it "the recipe has no extra outputs", ->
            @recipe.extras.should.eql {}

    describe "a modpack containg one mod for tools, and one for food: each containing full recipes", ->

        beforeEach ->
            @oldModA = fixtures.createMod modPack:@oldModPack, slug:"tools", name:"Tools"
            @oldModVersionA = fixtures.createModVersion mod:@oldModA, version:"1.1"
            fixtures.configureBucket @oldModVersionA
            fixtures.configureCraftingTable @oldModVersionA
            fixtures.configureFurnace @oldModVersionA
            fixtures.configureIronSword @oldModVersionA
            fixtures.configureIronShovel @oldModVersionA
            fixtures.configureSaw @oldModVersionA

            @oldModB = fixtures.createMod modPack:@oldModPack, slug:"food", name:"Food"
            @oldModVersionB = fixtures.createModVersion mod:@oldModB, version:"3.4.4"
            fixtures.configureCake @oldModVersionB

            @convert()

        it "has the right items in each mod", ->
            (itemId for itemId, item of @newModPack.mods["food"].items).sort().should.eql [
                "food__cake", "food__egg", "food__milk", "food__milk_bucket",
                "food__sugar", "food__sugar_cane", "food__wheat"
            ]
            (itemId for itemId, item of @newModPack.mods["tools"].items).sort().should.eql [
                "tools__bucket", "tools__coal", "tools__cobblestone", "tools__crafting_table", "tools__furnace",
                "tools__iron_block", "tools__iron_ingot", "tools__iron_ore", "tools__iron_shovel", "tools__iron_sword",
                "tools__oak_planks", "tools__oak_wood", "tools__redstone_dust", "tools__saw", "tools__stick"
            ]

        it "recipes with extras are converted correctly", ->
            recipe = @newModPack.mods["food"].items["food__cake"].firstRecipe
            (stack.item.displayName for itemId, stack of recipe.extras).sort().should.eql ["Bucket"]
            recipe.extras["tools__bucket"].quantity.should.equal 3
