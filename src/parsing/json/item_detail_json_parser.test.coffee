#
# Crafting Guide - item_detail_json_parser.test.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

fixtures             = require "../../models/fixtures"
ItemDetailJsonParser = require "./item_detail_json_parser"

########################################################################################################################

SAMPLE_TEXT = JSON.stringify JSON.parse """
    {
        "description": "alpha",
        "links": [
            { "name": "bravo", "url": "charlie" },
            { "name": "delta", "url": "echo" }
        ],
        "videos": [
            { "name": "foxtrot", "youTubeId": "golf" },
            { "name": "hotel", "youTubeId": "india" }
        ]
    }
"""

########################################################################################################################

describe "ItemDetailJsonParser", ->

    detail = item = mod = parser = text = null

    beforeEach ->
        mod = fixtures.createMod()
        item = fixtures.configureStick mod
        parser = new ItemDetailJsonParser item

    describe "parsing a fully-populated data object", ->

        beforeEach ->
            detail = parser.parse SAMPLE_TEXT

        it "connects to the given item", ->
            detail.item.should.equal item

        it "populates the description", ->
            detail.description.should.equal "alpha"

        it "populates the links", ->
            (link.name for link in detail.links).should.eql ["bravo", "delta"]

        it "populated the videos", ->
            (video.name for video in detail.videos).should.eql ["foxtrot", "hotel"]

        describe "then formatting the result", ->

            beforeEach -> text = parser.format detail

            it "yields the original string", ->
                text.should.equal SAMPLE_TEXT

