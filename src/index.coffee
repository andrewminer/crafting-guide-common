#
# Crafting Guide Common - index.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

module.exports =
    api:
        CraftingGuideClient:  require "./api/crafting_guide_client"
        ModPackStore:         require "./api/mod_pack_store"
        TestHttpServer:       require "./api/test_http_server"
        http:                 require "./api/http"

    deprecated:
        crafting:
            CraftingNode:     require "./deprecated/crafting/crafting_node"
            CraftingPlan:     require "./deprecated/crafting/crafting_plan"
            CraftingStep:     require "./deprecated/crafting/crafting_step"
            Craftsman:        require "./deprecated/crafting/craftsman"
            fixtures:         require "./deprecated/crafting/fixtures"
            GraphBuilder:     require "./deprecated/crafting/graph_builder"
            InventoryNode:    require "./deprecated/crafting/inventory_node"
            ItemNode:         require "./deprecated/crafting/item_node"
            PlanBuilder:      require "./deprecated/crafting/plan_builder"
            PlanEvaluator:    require "./deprecated/crafting/plan_evaluator"
            RecipeNode:       require "./deprecated/crafting/recipe_node"
            SimpleInventory:  require "./deprecated/crafting/simple_inventory"
            SimpleStack:      require "./deprecated/crafting/simple_stack"
        game:
            Inventory:        require "./deprecated/game/inventory"
            ItemSlug:         require "./deprecated/game/item_slug"
            Item:             require "./deprecated/game/item"
            ModPack:          require "./deprecated/game/mod_pack"
            ModVersion:       require "./deprecated/game/mod_version"
            Mod:              require "./deprecated/game/mod"
            Multiblock:       require "./deprecated/game/multiblock"
            Recipe:           require "./deprecated/game/recipe"
            SimpleStack:      require "./deprecated/game/simple_stack"
            Stack:            require "./deprecated/game/stack"
            Tutorial:         require "./deprecated/game/tutorial"
        parsing:
            ItemParser:       require "./deprecated/parsing/item_parser"
            ModParser:        require "./deprecated/parsing/mod_parser"
            ModVersionParser: require "./deprecated/parsing/mod_version_parser"
            TutorialParser:   require "./deprecated/parsing/tutorial_parser"
        BaseModel:            require "./deprecated/base_model"
        Converter:            require "./deprecated/converter"

    models:
        fixtures:             require "./models/fixtures"
        Inventory:            require "./models/inventory"
        Item:                 require "./models/item"
        ModPack:              require "./models/mod_pack"
        Mod:                  require "./models/mod"
        Recipe:               require "./models/recipe"
        Stack:                require "./models/stack"

    parsing:
        ModPackJsonFormatter: require "./parsing/json/mod_pack_json_formatter"
        ModPackJsonParser:    require "./parsing/json/mod_pack_json_parser"

    util:
        Logger:               require "./util/logger"
        Observable:           require "./util/observable"
        StringBuilder:        require "./util/string_builder"

    _:         require "./underscore"
    constants: require "./constants"

    defineResources: (JSData)->
        require("./js-data/mod")(JSData)
        require("./js-data/mod_ballot")(JSData)
        require("./js-data/mod_ballot_line")(JSData)
        require("./js-data/mod_vote")(JSData)
        require("./js-data/user")(JSData)
