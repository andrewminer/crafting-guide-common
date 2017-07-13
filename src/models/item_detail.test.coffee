#
# Crafting Guide Common - item_detail.test.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

fixtures   = require "./fixtures"
Item       = require "./item"
ItemDetail = require "./item_detail"
Link       = require "./link"
Observable = require "../util/observable"
Video      = require "./video"

########################################################################################################################

describe "ItemDetail", ->

    detail = item = link = mod = observer = video = null

    beforeEach ->
        mod = fixtures.createMod()
        item = fixtures.configureStick mod

    describe "with default values", ->

        beforeEach ->
            detail = new ItemDetail item:item
            observer = onEvent:sinon.spy()
            detail.on Observable::ANY, observer, "onEvent"

        it "the detail should refer to the item", ->
            detail.item.should.equal item

        it "the item should refer to the detail", ->
            item.detail.should.equal detail

        it "should have an empty description", ->
            detail.description.should.equal ""

        it "should have no links", ->
            detail.links.should.eql []

        it "should have no videos", ->
            detail.videos.should.eql []

        it "no events are fired", ->
            observer.onEvent.should.not.have.beenCalled

        describe "when changing the description", ->

            beforeEach -> detail.description = "alpha"

            it "should reflect the new description", ->
                detail.description.should.equal "alpha"

            it "should fire proper change events", ->
                observer.onEvent.should.have.been.calledWith Observable::PROP("description"), detail
                observer.onEvent.should.have.been.calledWith Observable::CHANGE, detail
                observer.onEvent.should.have.been.calledTwice

        describe "when adding a link", ->

            beforeEach -> detail.addLink new Link name:"alpha", url:"bravo"

            it "should contain the new link", ->
                (link.name for link in detail.links).should.eql ["alpha"]

            it "should fire the expected event", ->
                observer.onEvent.should.have.been.calledWith ItemDetail::ADD_LINK, detail

        describe "when adding a video", ->

            beforeEach -> detail.addVideo new Video name:"alpha", youTubeId:"bravo"

            it "should contain the new video", ->
                (video.name for video in detail.videos).should.eql ["alpha"]

            it "should fire the expected event", ->
                observer.onEvent.should.have.been.calledWith ItemDetail::ADD_VIDEO, detail

    describe "with provided values", ->

        beforeEach ->
            links = [new Link(name:"alpha", url:"bravo"), new Link(name:"charlie", url:"delta")]
            videos = [ new Video(name:"echo", youTubeId:"foxtrot"), new Video(name:"golf", youTubeId:"hotel")]
            detail = new ItemDetail item:item, description:"india", links:links, videos:videos

        it "the detail should refer to the item", ->
            detail.item.should.equal item

        it "the item should refer to the detail", ->
            item.detail.should.equal detail

        it "should have the given description", ->
            detail.description.should.equal "india"

        it "should have the given links", ->
            (link.name for link in detail.links).should.eql ["alpha", "charlie"]

        it "should have the given videos", ->
            (video.name for video in detail.videos).should.eql ["echo", "golf"]

        it "shouldn't fire any events", ->
            observer.onEvent.should.not.have.beenCalled

