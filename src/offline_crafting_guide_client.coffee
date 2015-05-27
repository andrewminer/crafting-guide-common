###
Crafting Guide Common - offline_crafting_guide_client.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

w = require 'when'

########################################################################################################################

module.exports = class CraftingGuideClient

    @Status: Status =
        Stale: 'stale'
        Down:  'down'
        Up:    'up'

    constructor: (options={})->
        options.onStatusChanged ?= (client, oldStatus, newStatus)-> # do nothing
        options.onLoginRequired ?= (client)-> # do nothing

        @_networkLatency = 300
        @_status         = Status.Stale

    # Public Methods ###############################################################################

    checkStatus: ->
        w(true).delay(@_networkLatency).then =>
            @_setStatus Status.Up

    reset: ->
        # do nothing

    startMonitoringStatus: ->
        # do nothing

    stopMonitoringStatus: ->
        # do nothing

    # Property Methods #############################################################################

    getStatus: ->
        return @_status

    Object.defineProperties @prototype,
        status: {get:@prototype.getStatus}

    # Request Methods ##############################################################################

    completeGitHubLogin: (args={})->
        return w.reject new Error 'args.code is required' unless args.code

        w(true).delay(@_networkLatency).then =>
            return json:data:user:
                email: 'andrewminer@mac.com'
                login: 'andrewminer'
                name: 'Andrew Miner'

    fetchCurrentUser: ->
        w(true).delay(@_networkLatency).then =>
            return json:data:user:
                email: 'andrewminer@mac.com'
                login: 'andrewminer'
                name: 'Andrew Miner'

    fetchFile: (args={})->
        return w.reject new Error 'args.path is required' unless args.path
        args.path = args.path.substring(1) if args.path[0] is '/'

        w(true).delay(@_networkLatency).then =>
            if args.path.match /.*item.cg$/
                return json:data:
                    content: """
                        schema: 1
                        description: <<-END
                            # Sample Description

                            This is a sample description for an item being edited.
                        END
                    """
                    sha:     '01234567890abcdef'
            else
                return json:data:{content:'', sha: '0123456789abcdef'}

    logout: ->
        w(true).delay(@_networkLatency).then =>
            return {}

    ping: (args={})->
        return w.reject new Error 'args.message is required' unless args.message

        w(true).delay(@_networkLatency).then =>
            return {}

    updateFile: (args={})->
        return w.reject new Error 'args.path is required' unless args.path
        return w.reject new Error 'args.message is required' unless args.message
        return w.reject new Error 'args.content is required' unless args.content
        args.path = args.path.substring(1) if args.path[0] is '/'

        url = "/github/file/#{args.path}"
        delete args.path

        w(true).delay(@_networkLatency).then =>
            return {}

    # Private Methods ##############################################################################

    _setStatus: (newStatus)->
        oldStatus = @_status
        return if newStatus is oldStatus

        @_status = newStatus
        @onStatusChanged.call null, this, oldStatus, newStatus
