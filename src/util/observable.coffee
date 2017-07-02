#
# Crafting Guide Common - observable.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_ = require "../underscore"

########################################################################################################################

module.exports = class Observable

    constructor: ->
        @_eventSources  = []
        @_firing        = false
        @_isMuted       = false
        @_isChangeMuted = false
        @_listeners     = {}
        @_listeningTo   = []

    # Class Properties #############################################################################

    @::ANY       = "any"
    @::CHANGE    = "change"
    @::DELIMITER = ":"
    @::PROP      = (name)-> return "#{Observable::CHANGE}#{Observable::DELIMITER}#{name}"

    # Properties ###################################################################################

    Object.defineProperties @prototype,

        isObservable:
            get: -> return true

    # Public Methods ###############################################################################

    hasListener: (event, target, action)->
        return @_findListener(event, target, action)?

    on: (event, target, action)->
        @_on event, target, action

    once: (event, target, action)->
        @_on event, target, action, once:true

    off: (options={})->
        {event, target, action} = options
        if not (event? or target? or action?)
            @_listeners = {}
            return this

        searchLists = []
        if not event?
            searchLists = (list for event, list of @_listeners)
        else
            eventListeners = @_listeners[event]
            if eventListeners.length >= 1
                searchLists.push eventListeners

        return this unless searchLists.length > 0
        for listenerList in searchLists
            index = 0
            while index < listenerList.length
                listener = listenerList[index]
                targetMatches = (not target?) or (listener.target is target)
                actionMatches = (not action?) or (listener.action is action)
                if targetMatches and actionMatches
                    listenerList.splice index, 1
                else
                    index++

        return this

    stopListening: ->
        for source in @_listeningTo
            source.off target:this

        @_listeningTo = []

    # Protected Methods ############################################################################

    muted: (callback)->
        @_isMuted = true
        try
            callback.call this
        finally
            @_isMuted = false

    trigger: (event, args...)->
        return if @_isMuted
        return this unless @_listeners[event]? or @_listeners[@ANY]?

        if @_firing then throw new Error "event cycle detected while firing #{event}"
        @_firing = true

        args.unshift this
        args.unshift event
        [a0, a1, a2, a3, a4] = args

        errors = []
        listeners = _.compact _.flatten [@_listeners[@ANY], @_listeners[event]]
        for listener in listeners
            callback = listener.target[listener.action]
            try
                if not _.isFunction(callback)
                    throw new Error "#{listener.action} of #{listener.target} is no longer a function"

                switch args.length
                    when 2 then callback.call listener.target, a0, a1
                    when 3 then callback.call listener.target, a0, a1, a2
                    when 4 then callback.call listener.target, a0, a1, a2, a3
                    when 5 then callback.call listener.target, a0, a1, a2, a3, a4
                    else callback.apply listener.target, args
            catch e
                errors.push {target:listener.target, action:listener.action, error:e}

            if listener.once
                @off event:event, target:listener.target, action:listener.action

        @_firing = false

        if errors.length > 0
            error = new Error "#{errors.length} errors occurred during delivery"
            error.errors = errors
            throw error

        return this

    triggerPropertyChange: (name, oldValue, newValue, callback)->
        return false if oldValue is newValue

        if callback?
            wasChangeMuted = @_isChangeMuted
            @_isChangeMuted = true
            callback.call this, oldValue, newValue
            @_isChangeMuted = wasChangeMuted
        else
            this["_#{name}"] = newValue

        @trigger @PROP(name), oldValue, newValue
        if not @_isChangeMuted then @trigger @CHANGE

        return true

    # Private Methods ##############################################################################

    _findListener: (event, target, action)->
        return null unless @_listeners[event]?

        for listener in @_listeners[event]
            if (listener.target is target) and (listener.action is action)
                return listener

        return null

    _on: (event, target, action, options={})->
        if not _.isString(event) then throw new Error "event must be a string"
        if not target? then throw new Error "target is required"
        if not action? then throw new Error "action is required"
        if not _.isFunction(target[action]) then throw new Error "target[action] must be a function"

        listener = @_findListener event, target, action
        if not listener?
            eventListeners = @_listeners[event] ?= []
            listener = target:target, action:action
            eventListeners.push listener

        listener.once = !!options.once

        if target.constructor is Observable
            target._listeningTo.push this

        return this
