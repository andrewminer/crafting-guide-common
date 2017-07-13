#
# Crafting Guide Common - mod_pack_store.test.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

c                    = require "../constants"
fixtures             = require "../models/fixtures"
ModPackStore         = require "./mod_pack_store"
ModPackJsonFormatter = require "../parsing/json/mod_pack_json_formatter"
w                    = require "when"

########################################################################################################################

baseUrl = deferred = http = loading = loadResult = store = null

########################################################################################################################

describe "ModPackStore", ->

    beforeEach ->
        baseUrl = "http://localhost:8080/api"
        loading = null
        http    = get:sinon.stub().callsFake -> return loading
        store   = new ModPackStore http:http, baseUrl:baseUrl

    describe "by default", ->

        it "returns undefined for any requested mod pack", ->
            expect(store.get("default")).toBeUndefined

    describe "once loading has begun", ->

        beforeEach ->
            deferred = w.defer()
            loading = deferred.promise
            loadResult = store.load "default"
            return # avoid returning the promise

        it "returns a promise when load is called", ->
            w.isPromiseLike(loadResult).should.equal true
            loadResult.inspect().state.should.equal "pending"

        it "still returns undefined for the mod pack itself", ->
            expect(store.get("default")).toBeUndefined

        it "made an HTTP call for the raw data", ->
            url = baseUrl + c.url.modPackArchive modPackId:"default"
            http.get.should.be.calledWith url

        describe "when loading is complete", ->

            beforeEach ->
                modPack = fixtures.createModPack id:"test", name:"Test"
                mod = fixtures.createMod id:"minecraft", name:"Minecraft", modPack:modPack
                fixtures.configureBucket mod

                formatter = new ModPackJsonFormatter
                deferred.resolve statusCode:200, body:formatter.format modPack
                return loadResult

            it "returns a properly formed mod pack from `get`", ->
                modPack = store.get "default"
                modPack.id.should.equal "test"
                (id for id, mod of modPack.mods).should.eql ["minecraft"]
                ((itemId for itemId, item of mod.items).sort() for modId, mod of modPack.mods).should.eql [[
                    "bucket", "coal", "cobblestone", "crafting_table", "furnace", "iron_ingot", "iron_ore",
                    "oak_planks", "oak_wood"
                ]]

            it "still returns undefined for unloaded mod packs", ->
                expect(store.get("other")).toBeUndefined

            describe "when loading the same mod pack again", ->

                beforeEach ->
                    loadResult = store.load "default"
                    return # avoid returning the promise

                it "does not make a second HTTP call", ->
                    http.get.should.be.calledOnce

                it "returns an already-fulfilled promise", ->
                    loadResult.inspect().state.should.equal "fulfilled"

                it "the load promise resolves to the mod pack returned by the store", ->
                    loadResult.inspect().value.should.equal store.get "default"

        describe "when loading fails", ->

            beforeEach ->
                deferred.resolve statusCode:404, body:"Unknown Mod Pack"
                return loadResult.catch -> # it's expected to fail

            it "the loading promise resolves to the expected error", ->
                loadResult.inspect().state.should.equal "rejected"
                loadResult.catch (error)->
                    error.message.should.equal "404 Unknown Mod Pack"
