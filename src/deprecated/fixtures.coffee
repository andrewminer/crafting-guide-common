#
# Crafting Guide Common - fixtures.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_           = require "../underscore"
Item        = require "./game/item"
ItemSlug    = require "./game/item_slug"
Mod         = require "./game/mod"
ModVersion  = require "./game/mod_version"
ModPack     = require "./game/mod_pack"
Multiblocks = require "./game/multiblock"
Recipe      = require "./game/recipe"
Stack       = require "./game/stack"

# Instance Creation Fixtures ###########################################################################################

exports.createModPack = createModPack = (attributes={})->
    return new ModPack attributes

exports.createMod = createMod = (attributes={})->
    attributes.modPack ?= createModPack()
    attributes.slug ?= _.uniqueId "mod-"
    attributes.name ?= "Test Mod"
    mod = new Mod attributes

    attributes.modPack.addMod mod
    return mod

exports.createModVersion = createModVersion = (attributes={})->
    attributes.mod ?= createMod()
    attributes.modSlug = attributes.mod.slug
    attributes.version ?= _.uniqueId "mod-version-"
    modVersion = new ModVersion attributes

    attributes.mod.addModVersion modVersion
    return modVersion

exports.createItem = createItem = (attributes={})->
    if not attributes.name? then throw new Error "expected a name"
    attributes.modVersion ?= createModVersion()
    attributes.name ?= _.uniqueId "Test Item "
    item = new Item attributes

    attributes.modVersion.addItem item
    return item

exports.createRecipe = createRecipe = (attributes={})->
    attributes.input ?= [createStack item:createItem(attributes)]
    attributes.output ?= [createStack item:createItem(attributes)]
    attributes.pattern ?= "... .0. ..."
    return new Recipe attributes

exports.createStack = createStack = (attributes={})->
    attributes.item ?= createItem(attributes).slug
    attributes.itemSlug ?= attributes.item.slug
    attributes.quantity ?= 1
    return new Stack attributes

# Item Configuration Fixtures ##########################################################################################

exports.configureBucket = configureBucket = (modVersion)->
    bucket = modVersion.mod.modPack.findItemByName "Bucket"
    if not bucket?
        ironIngot     = configureIronIngot modVersion
        bucket        = createItem modVersion:modVersion, name:"Bucket"
        craftingTable = configureCraftingTable modVersion

        modVersion.addRecipe createRecipe
            input:[createStack item:ironIngot]
            output:[createStack item:bucket]
            pattern:"0.0 .0. ..."
            tools:[createStack item:craftingTable]

    return bucket

exports.configureCake = configureCake = (modVersion)->
    cake = modVersion.mod.modPack.findItemByName "Cake"
    if not cake?
        bucket        = configureBucket modVersion
        cake          = createItem modVersion:modVersion, name:"Cake"
        craftingTable = configureCraftingTable modVersion
        egg           = configureEgg modVersion
        milkBucket    = configureMilkBucket modVersion
        sugar         = configureSugar modVersion
        wheat         = configureWheat modVersion

        modVersion.addRecipe createRecipe
            input: [
                createStack item:milkBucket
                createStack item:sugar
                createStack item:egg
                createStack item:wheat
            ]
            output: [createStack(item:cake), createStack(item:bucket, quantity:3)]
            pattern: "000 121 333"
            tools: [createStack item:craftingTable]

    return cake

exports.configureCoal = configureCoal = (modVersion)->
    coal = modVersion.mod.modPack.findItemByName "Coal"
    if not coal?
        coal = createItem modVersion:modVersion, name:"Coal"
    return coal

exports.configureCobblestone = configureCobblestone = (modVersion)->
    cobblestone = modVersion.mod.modPack.findItemByName "Cobblestone"
    if not cobblestone?
        cobblestone = createItem modVersion:modVersion, name:"Cobblestone"
    return cobblestone

exports.configureCraftingTable = configureCraftingTable = (modVersion)->
    craftingTable = modVersion.mod.modPack.findItemByName "Crafting Table"
    if not craftingTable?
        craftingTable = createItem modVersion:modVersion, name:"Crafting Table"
        oakPlanks     = configureOakPlanks modVersion

        modVersion.addRecipe createRecipe
            input:[createStack item:oakPlanks]
            output:[createStack item:craftingTable]
            pattern:"00. 00. ..."

    return craftingTable

exports.configureEgg = configureEgg = (modVersion)->
    egg = modVersion.mod.modPack.findItemByName "Egg"
    if not egg?
        egg = createItem modVersion:modVersion, name:"Egg"
    return egg

exports.configureFurnace = configureFurnace = (modVersion)->
    furnace = modVersion.mod.modPack.findItemByName "Furnace"
    if not furnace?
        cobblestone   = configureCobblestone modVersion
        craftingTable = configureCraftingTable modVersion
        furnace       = createItem modVersion:modVersion, name:"Furnace"

        modVersion.addRecipe createRecipe
            input:[createStack item:cobblestone]
            output:[createStack item:furnace]
            pattern:"000 0.0 000"
            tools:[createStack item:craftingTable]

    return furnace

exports.configureIronIngot = configureIronIngot = (modVersion)->
    ironIngot = modVersion.mod.modPack.findItemByName "Iron Ingot"
    if not ironIngot?
        coal      = configureCoal modVersion
        furnace   = configureFurnace modVersion
        ironIngot = createItem modVersion:modVersion, name:"Iron Ingot"
        ironOre   = configureIronOre modVersion

        modVersion.addRecipe createRecipe
            input:[createStack(item:ironOre, quantity:8), createStack(item:coal)]
            output:[createStack item:ironIngot, quantity:8]
            tools:[createStack item:furnace]

    return ironIngot

exports.configureIronBlock = configureIronBlock = (modVersion)->
    ironBlock = modVersion.mod.modPack.findItemByName "Iron Block"
    if not ironBlock?
        craftingTable = configureCraftingTable modVersion
        ironBlock = createItem modVersion:modVersion, name:"Iron Block"
        ironIngot = configureIronIngot modVersion

        modVersion.addRecipe createRecipe
            input:[createStack item:ironIngot]
            output:[createStack item:ironBlock]
            pattern:"000 000 000"
            tools:[createStack(item:craftingTable)]

        modVersion.addRecipe createRecipe
            input:[createStack item:ironBlock]
            output:[createStack item:ironIngot, quantity:9]
            pattern:"0.. ... ..."

    return ironBlock

exports.configureIronSword = configureIronSword = (modVersion)->
    ironSword = modVersion.mod.modPack.findItemByName "Iron Sword"
    if not ironSword?
        craftingTable = configureCraftingTable modVersion
        ironIngot     = configureIronIngot modVersion
        ironSword     = createItem modVersion:modVersion, name:"Iron Sword"
        stick         = configureStick modVersion

        modVersion.addRecipe createRecipe
            input:[createStack(item:ironIngot), createStack(item:stick)]
            output:[createStack item:ironSword]
            pattern:".0. .0. .1."
            tools:[createStack item:craftingTable]

    return ironSword

exports.configureIronShovel = configureIronShovel = (modVersion)->
    ironShovel = modVersion.mod.modPack.findItemByName "Iron Shovel"
    if not ironShovel?
        craftingTable = configureCraftingTable modVersion
        ironIngot     = configureIronIngot modVersion
        ironShovel    = createItem modVersion:modVersion, name:"Iron Shovel"
        stick         = configureStick modVersion

        modVersion.addRecipe createRecipe
            input:[createStack(item:ironIngot), createStack(item:stick)]
            output:[createStack item:ironShovel]
            pattern:".0. .1. .1."
            tools:[createStack item:craftingTable]

    return ironShovel

exports.configureIronOre = configureIronOre = (modVersion)->
    ironOre = modVersion.mod.modPack.findItemByName "Iron Ore"
    if not ironOre?
        ironOre = createItem modVersion:modVersion, name:"Iron Ore"
    return ironOre

exports.configureMilk = configureMilk = (modVersion)->
    milk = modVersion.mod.modPack.findItemByName "Milk"
    if not milk?
        milk = createItem modVersion:modVersion, name:"Milk"
    return milk

exports.configureMilkBucket = configureMilkBucket = (modVersion)->
    milkBucket = modVersion.mod.modPack.findItemByName "Milk Bucket"
    if not milkBucket?
        bucket     = configureBucket modVersion
        milk       = configureMilk modVersion
        milkBucket = createItem modVersion:modVersion, name:"Milk Bucket"

        modVersion.addRecipe createRecipe
            input:[createStack(item:bucket), createStack(item:milk)]
            output:[createStack item:milkBucket]
            pattern:".1. .0. ..."

    return milkBucket

exports.configureOakPlanks = configureOakPlanks = (modVersion)->
    oakPlanks = modVersion.mod.modPack.findItemByName "Oak Planks"
    if not oakPlanks?
        oakPlanks = createItem modVersion:modVersion, name:"Oak Planks"
        oakWood   = configureOakWood modVersion

        modVersion.addRecipe createRecipe
            input:[createStack item:oakWood]
            output:[createStack item:oakPlanks, quantity:4]
            pattern:"0.. ... ..."

    return oakPlanks

exports.configureOakWood = configureOakWood = (modVersion)->
    oakWood = modVersion.mod.modPack.findItemByName "Oak Wood"
    if not oakWood?
        oakWood = createItem modVersion:modVersion, name:"Oak Wood"
    return oakWood

exports.configureObsidian = configureObsidian = (modVersion)->
    obsidian = modVersion.mod.modPack.findItemByName "obsidian"
    if not obsidian?
        obsidian = createItem modVersion:modVersion, name:"Obsidian"
    return obsidian

exports.configureRedstone = configureRedstone = (modVersion)->
    redstoneDust = modVersion.mod.modPack.findItemByName "Redstone"
    if not redstoneDust?
        slug = new ItemSlug modVersion.modSlug, "redstone_dust"
        redstoneDust = createItem modVersion:modVersion, name:"Redstone", slug:slug
    return redstoneDust

exports.configureStick = configureStick = (modVersion)->
    stick = modVersion.mod.modPack.findItemByName "Stick"
    if not stick?
        oakPlanks = configureOakPlanks modVersion
        stick     = createItem modVersion:modVersion, name:"Stick"

        modVersion.addRecipe createRecipe
            input: [createStack item:oakPlanks]
            output: [createStack item:stick, quantity:4]
            pattern: "0.. 0.. ..."

    return stick

exports.configureSugar = configureSugar = (modVersion)->
    sugar = modVersion.mod.modPack.findItemByName "Sugar"
    if not sugar?
        sugar     = createItem modVersion:modVersion, name:"Sugar"
        sugarCane = configureSugarCane modVersion

        modVersion.addRecipe createRecipe
            input: [createStack item:sugarCane]
            output: [createStack item:sugar]
            pattern: "0.. ... ..."

    return sugar

exports.configureSaw = configureSaw = (modVersion)->
    saw = modVersion.mod.modPack.findItemByName "saw"
    if not saw?
        craftingTable = configureCraftingTable modVersion
        ironBlock     = configureIronBlock modVersion
        ironIngot     = configureIronIngot modVersion
        oakPlanks     = configureOakPlanks modVersion
        oakWood       = configureOakWood modVersion
        redstoneDust  = configureRedstone modVersion
        saw           = createItem modVersion:modVersion, name:"Saw"

        modVersion.addRecipe createRecipe
            input: [
                createStack item:oakPlanks
                createStack item:ironIngot
                createStack item:ironBlock
                createStack item:redstoneDust
            ]
            output: [createStack item:saw]
            pattern: "010 020 030"
            tools: [createStack item:craftingTable]

        modVersion.addRecipe createRecipe
            input: [createStack item:oakWood]
            output: [createStack item:oakPlanks, quantity:8]
            pattern: "0.. ... ..."
            tools: [createStack item:saw]

    return saw

exports.configureSugarCane = configureSugarCane = (modVersion)->
    sugarCane = modVersion.findItem "Sugar Cane"
    if not sugarCane?
        sugarCane = createItem modVersion:modVersion, name:"Sugar Cane"
    return sugarCane

exports.configureWheat = configureWheat = (modVersion)->
    wheat = modVersion.findItem "Wheat"
    if not wheat?
        wheat = createItem modVersion:modVersion, name:"Wheat"
    return wheat
