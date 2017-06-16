# Crafting Guide Common - observable.test.coffee
#
# Copyright (c) 2015 by Redwood Labs
# All rights reserved.
#

Observable = require "./observable"

########################################################################################################################

describe "Observable", ->

    error = newSpy = oldSpy = source = source2 = target = target2 = null

    beforeEach ->
        source = new Observable
        source.toString = -> return "source"

        source2 = new Observable
        source2.toString = -> return "source2"

        target = new Observable
        target.onAction = sinon.spy()
        target.onAction2 = sinon.spy()
        target.toString = -> return "target"

        target2 = new Observable
        target2.onAction = sinon.spy()
        target2.onAction2 = sinon.spy()
        target2.toString = -> return "target2"

    describe "by default", ->

        describe "firing an event", ->

            beforeEach -> source.trigger "event"

            it "doesn't trigger anything", ->
                target.onAction.should.not.haveBeenCalled

    describe "attempting to register an invalid event name", ->

        it "should throw an error about the event", ->
            expect(-> source.on()).to.throw /event.*/

    describe "attempting to register an invalid target", ->

        it "should throw an error about the target", ->
            expect(-> source.on "event").to.throw /target.*/

    describe "attempting to register without an action", ->

        it "should throw an error about the missing action", ->
            expect(-> source.on "event", {}).to.throw /action.*/

    describe "attempting to register an action not on the target", ->

        it "should throw an error about the mismatch", ->
            expect(-> source.on "event", {}, "action").to.throw /.*must be a function/

    describe "after registering a `once` handler and firing an event", ->

        beforeEach ->
            source.once "event", target, "onAction"
            source.trigger "event"

        it "target.onAction was called", ->
            target.onAction.should.have.been.calledWith "event", source
            target.onAction.should.have.been.calledOnce

        it "the listener should have been removed", ->
            source.hasListener("event", target, "onAction").should.equal false

        describe "when the event is fired again", ->

            beforeEach -> source.trigger "event"

            it "the target didn't get called again", ->
                target.onAction.should.have.been.calledOnce

    describe "after registering an `any` handler and firing some events", ->

        beforeEach ->
            source.on Observable::ANY, target, "onAction"
            source.trigger "event"
            source.trigger "event2"

        it "triggers the action handler for each action", ->
            target.onAction.should.have.been.calledWith "event", source
            target.onAction.should.have.been.calledWith "event2", source
            target.onAction.should.have.been.calledTwice

    describe "firing events while muted", ->

        beforeEach ->
            source.on "event", target, "onAction"

            source.trigger "event"
            source.muted -> source.trigger "event"
            source.trigger "event"

        it "the event handler is only called outside the muted block", ->
            target.onAction.should.be.calledTwice

    describe "after registering a simple target & action and then firing an event", ->

        beforeEach ->
            source.on "event", target, "onAction"
            source.trigger "event"

        it "the event is delivered", ->
            target.onAction.should.have.been.calledOnce

        describe "when the action function gets swapped and another action is fired", ->

            beforeEach ->
                oldSpy = target.onAction
                newSpy = sinon.spy()
                target.onAction = newSpy
                source.trigger "event"

            it "the old action should have been called again", ->
                oldSpy.should.have.been.calledOnce

            it "the new action method should be called instead", ->
                newSpy.should.have.been.calledOnce

        describe "if the action handler is removed and an event fired", ->

            beforeEach ->
                source.on "event", target2, "onAction"
                oldSpy = target.onAction
                oldSpy.reset()
                delete target.onAction

                try
                    source.trigger "event"
                catch e
                    error = e

                return

            it "the trigger call should throw a summary error", ->
                error.message.should.match /errors occurred/
                error.errors.length.should.equal 1

                error = error.errors[0]
                error.error.message.should.match /no longer a function/
                error.target.should.equal target
                error.action.should.equal "onAction"

            it "the old action handler should not get called", ->
                oldSpy.should.not.have.been.called

            it "other handlers should still get called", ->
                target2.onAction.should.have.been.called

    describe "after registering a combination of distinct targets and actions", ->

        beforeEach ->
            source.on "event", target, "onAction"
            source.on "event2", target, "onAction2"
            source.on "event", target2, "onAction"
            source.on "event2", target2, "onAction2"
            source2.on "event", target, "onAction"
            source2.on "event2", target, "onAction2"
            source2.on "event", target2, "onAction"
            source2.on "event2", target2, "onAction2"

        it "all the appropriate listeners have been registered", ->
            source.hasListener("event", target, "onAction").should.equal true
            source.hasListener("event2", target, "onAction2").should.equal true
            source.hasListener("event", target2, "onAction").should.equal true
            source.hasListener("event2", target2, "onAction2").should.equal true
            source2.hasListener("event", target, "onAction").should.equal true
            source2.hasListener("event2", target, "onAction2").should.equal true
            source2.hasListener("event", target2, "onAction").should.equal true
            source2.hasListener("event2", target2, "onAction2").should.equal true

        describe "firing `event` from `source`", ->

            beforeEach -> source.trigger "event"

            it "only onAction is called for both targets", ->
                target.onAction.should.have.been.calledWith "event", source
                target.onAction.should.have.been.calledOnce
                target.onAction2.should.not.have.been.called

                target2.onAction.should.have.been.calledWith "event", source
                target2.onAction.should.have.been.calledOnce
                target2.onAction2.should.not.have.been.called

        describe "firing `event2` from `source`", ->

            beforeEach -> source.trigger "event2"

            it "only onAction2 is fired on both targets", ->
                target.onAction.should.not.have.been.called
                target.onAction2.should.have.been.calledWith "event2", source
                target.onAction2.should.have.been.calledOnce

                target2.onAction.should.not.have.been.called
                target2.onAction2.should.have.been.calledWith "event2", source
                target2.onAction2.should.have.been.calledOnce

        describe "firing `event` and `event2` from `source2`", ->

            beforeEach ->
                source2.trigger "event"
                source2.trigger "event2"

            it "both onAction and onAction2 is fired on both targets", ->
                target.onAction.should.have.been.calledWith "event", source2
                target.onAction.should.have.been.calledOnce

                target.onAction2.should.have.been.calledWith "event2", source2
                target.onAction2.should.have.been.calledOnce

                target2.onAction.should.have.been.calledWith "event", source2
                target2.onAction.should.have.been.calledOnce

                target2.onAction2.should.have.been.calledWith "event2", source2
                target2.onAction2.should.have.been.calledOnce

        describe "firing `event` from `source` and `source2`", ->

            beforeEach ->
                source.trigger "event"
                source2.trigger "event"

            it "onAction is fired on each target once for each source", ->
                target.onAction.should.have.been.calledWith "event", source
                target.onAction.should.have.been.calledWith "event", source2
                target.onAction.should.have.been.calledTwice

                target2.onAction.should.have.been.calledWith "event", source
                target2.onAction.should.have.been.calledWith "event", source2
                target2.onAction.should.have.been.calledTwice

        describe "after removing `event` listeners from both sources", ->

            beforeEach ->
                source.off event:"event"
                source2.off event:"event"

            it "all the listeners for `event` have been removed", ->
                source.hasListener("event", target, "onAction").should.equal false
                source.hasListener("event", target2, "onAction").should.equal false
                source2.hasListener("event", target, "onAction").should.equal false
                source2.hasListener("event", target2, "onAction").should.equal false

            it "all listeners for `event2` are unaffected", ->
                source.hasListener("event2", target, "onAction2").should.equal true
                source.hasListener("event2", target2, "onAction2").should.equal true
                source2.hasListener("event2", target, "onAction2").should.equal true
                source2.hasListener("event2", target2, "onAction2").should.equal true

        describe "after removing `target` listeners from both sources", ->

            beforeEach ->
                source.off target:target
                source2.off target:target

            it "all the listeners for `target` have been removed", ->
                source.hasListener("event", target, "onAction").should.equal false
                source.hasListener("event2", target, "onAction2").should.equal false
                source2.hasListener("event", target, "onAction").should.equal false
                source2.hasListener("event2", target, "onAction2").should.equal false

            it "all listeners for `target2` are unaffected", ->
                source.hasListener("event", target2, "onAction").should.equal true
                source.hasListener("event2", target2, "onAction2").should.equal true
                source2.hasListener("event", target2, "onAction").should.equal true
                source2.hasListener("event2", target2, "onAction2").should.equal true

        describe "after removing `onAction` listeners from both sources", ->

            beforeEach ->
                source.off action:"onAction"
                source2.off action:"onAction"

            it "all listeners for `onAction` have been removed", ->
                source.hasListener("event", target, "onAction").should.equal false
                source.hasListener("event", target2, "onAction").should.equal false
                source2.hasListener("event", target, "onAction").should.equal false
                source2.hasListener("event", target2, "onAction").should.equal false

            it "all listeners for `onAction2` are unaffected", ->
                source.hasListener("event2", target, "onAction2").should.equal true
                source.hasListener("event2", target2, "onAction2").should.equal true
                source2.hasListener("event2", target, "onAction2").should.equal true
                source2.hasListener("event2", target2, "onAction2").should.equal true

        describe "after removing all listners from both sources", ->

            beforeEach ->
                source.off()
                source2.off()

            it "all the listeners have been removed", ->
                source.hasListener("event", target, "onAction").should.equal false
                source.hasListener("event2", target, "onAction2").should.equal false
                source.hasListener("event", target2, "onAction").should.equal false
                source.hasListener("event2", target2, "onAction2").should.equal false
                source2.hasListener("event", target, "onAction").should.equal false
                source2.hasListener("event2", target, "onAction2").should.equal false
                source2.hasListener("event", target2, "onAction").should.equal false
                source2.hasListener("event2", target2, "onAction2").should.equal false

        describe "after `target` stops listening", ->

            beforeEach -> target.stopListening()

            it "all the listeners for `target` have been removed", ->
                source.hasListener("event", target, "onAction").should.equal false
                source.hasListener("event2", target, "onAction2").should.equal false
                source2.hasListener("event", target, "onAction").should.equal false
                source2.hasListener("event2", target, "onAction2").should.equal false

            it "all listeners for `target2` are unaffected", ->
                source.hasListener("event", target2, "onAction").should.equal true
                source.hasListener("event2", target2, "onAction2").should.equal true
                source2.hasListener("event", target2, "onAction").should.equal true
                source2.hasListener("event2", target2, "onAction2").should.equal true
