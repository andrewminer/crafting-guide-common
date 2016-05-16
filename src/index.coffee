#
# Crafting Guide - index.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

module.exports =
    CraftingGuideClient:        require './crafting_guide_client'
    OfflineCraftingGuideClient: require './offline_crafting_guide_client'
    Logger:                     require './logger'
    StringBuilder:              require './string_builder'
    TestHttpServer:             require './test_http_server'
    http:                       require './http'
    stringMixins:               require './string_mixins'

    defineResources: (JSData)->
        require('./js-data/mod')(JSData)
        require('./js-data/mod_vote')(JSData)
        require('./js-data/user')(JSData)
