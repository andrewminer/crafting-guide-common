#
# Crafting Guide - crafting_guide_client.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

_    = require 'underscore'
http = require './http'
w    = require 'when'

########################################################################################################################

module.exports = class CraftingGuideClient

    @SESSION_COOKIE = 'session' # do not change!

    @Status: Status =
        Stale: 'stale'
        Down:  'down'
        Up:    'up'

    constructor: (options={})->
        options.baseUrl          ?= 'http://localhost:8000'
        options.headers          ?= {}
        options.onStatusChanged  ?= (client, oldStatus, newStatus)-> # do nothing
        options.onSessionChanged ?= (session)-> # do nothing
        options.onLoginRequired  ?= (client)-> # do nothing

        @baseUrl          = options.baseUrl
        @onSessionChanged = options.onSessionChanged
        @onStatusChanged  = options.onStatusChanged
        @onLoginRequired  = options.onLoginRequired

        @_headers        = options.headers
        @_session        = options.session
        @_lastStatusTime = 0
        @_monitorStatus  = false
        @_checkingStatus = false
        @_status         = Status.Stale
        @_statusMaxAge   = 60000

    # Public Methods ###############################################################################

    checkStatus: ->
        return if @_checkingStatus
        @_checkingStatus = true

        message = _.uuid()
        @ping message:message
            .timeout @_statusMaxAge
            .then (response)=>
                if response.json.message is message
                    @_setStatus Status.Up
                else
                    throw new Error "Invalid server ping response: #{response.json.message} isnt #{message}"
            .catch (error)=>
                @_setStatus Status.Down
            .finally =>
                @_checkingStatus = false
                checkAgain = => if @_monitorStatus then @checkStatus()
                setTimeout checkAgain, @_statusMaxAge / 2

    startMonitoringStatus: ->
        @_monitorStatus = true
        @checkStatus()

    stopMonitoringStatus: ->
        @_monitorStatus = false

    # Property Methods #############################################################################

    getStatus: ->
        if Date.now() > @_lastStatusTime + @_statusMaxAge then return Status.Stale
        return @_status

    Object.defineProperties @prototype,
        status: { get:@prototype.getStatus }

    # Root-Level Request Methods ###################################################################

    # Checks that the server is running by sending a piece of text to the server and back.
    #
    # @param args.message   a message to be sent to the server
    # @return               a JSON object containing:
    #       status:         either 'success' or 'failure'
    #       message:        args.message if successful or an error message if there was an error
    ping: (args={})->
        return w.reject new Error 'args.message is required' unless args.message
        @_sendRequest http.get, '/ping', body:args

    # GitHub Request Methods #######################################################################

    # Creates a new server session by completing the OAuth process with GtiHub.
    #
    # @param args.code  the authentication code give by GitHub in the return redirect
    # @return           a JSON object containing:
    #       status:     either 'success' or 'failure'
    #       message:    an error message if there was an error
    #       data:       a JSData User model
    createSession: (args={})->
        return w.reject new Error 'args.code is required' unless args.code
        @_sendRequest http.post, '/github/session', body:args

    # Clears out the user's session
    deleteSession: ->
        @_sendRequest http.delete, '/github/session'

    # Fetches a file from GitHub and returns it along with some meta data.
    #
    # @param args.path  the full path in the `crafting-guide-data` repo of the desired file
    # @return               a JSON object containing:
    #       status:         either 'success' or 'error'
    #       message:        an error message if there was an error
    #       data:           a JSON hash describing the file
    #           content:    the base64-encoded content of the file
    #           path:       the full path of the file (matches args.path)
    #           sha:        the SHA1 digest of the file's current content
    fetchFile: (args={})->
        return w.reject new Error 'args.path is required' unless args.path
        args.path = args.path.substring(1) if args.path[0] is '/'
        @_sendRequest http.get, "/github/file/#{args.path}"

    # Commits a file to GitHub. This can work with either a brand new file (no SHA) or an existing file (with a SHA).
    # Attempting to update a file which already exists without providing the most recent SHA for that file will cause
    # the request to fail. This will be the case, for example, if someone else has updated the file while the user was
    # making his edits.
    #
    # @param args.path      the full path of the file in the `crafting-guide-data` repository
    # @param args.message   the message to be used when committing the file
    # @param args.content   the base64-encoded content of the file
    # @param args.sha       the SHA1 digest of the previous version of the file (only if updating)
    # @return               a JSON object containing:
    #       status:         either 'success' or 'error'
    #       message:        an error message if there was an error
    updateFile: (args={})->
        return w.reject new Error 'args.path is required' unless args.path
        return w.reject new Error 'args.message is required' unless args.message
        return w.reject new Error 'args.content is required' unless args.content
        args.path = args.path.substring(1) if args.path[0] is '/'

        url = "/github/file/#{args.path}"
        delete args.path

        @_sendRequest http.put, url, body:args

    # ModBallot Methods ############################################################################

    # Fetches the current list of mods available for voting along with related data.  This is the same data for all
    # users and reflects the latest cumulative votes from all users.
    #
    # @return               a hash of a ModBallot JSData model object
    getModBallot: ->
        @_sendRequest http.get, '/modBallot'

    # ModVote Methods ##############################################################################

    # Fetches the list of the current user's ModVotes.
    #
    # @return               an array of hashes generated from the ModVote JSData model
    getModVotes: ->
        @_sendRequest http.get, '/modVotes'

    # Casts a vote for a specific mod on behalf of the current user.  The user is only permitted a limited number of
    # votes, so the server may return an error of this has been exceeded.
    #
    # @param args.modId     the ID of the mod to vote for
    # @return               a hash containing:
    #       status:         either 'success' or 'error'
    #       message:        an error message if there was an error
    castVote: (args={})->
        return w.reject new Error 'args.modId is required' unless args.modId
        @_sendRequest http.post, '/modVotes', body:{modId:args.modId}

    # Cancels the user's vote for a certain mod.
    #
    # @param args.modVoteId     the ID of the ModVote to cancel
    # @return                   a hash containing:
    #       status:             either 'success' or 'error'
    #       message:            an error message if there was an error
    cancelVote: (args={})->
        return w.reject new Error 'args.modVoteId is required' unless args.modVoteId
        @_sendRequest http.delete, "/modVotes/#{args.modVoteId}"

    # User Methods #################################################################################

    getCurrentUser: ->
        @_sendRequest http.get, '/users/current'

    # Private Methods ##############################################################################

    _attemptJsonParsing: (response)->
        try
            response.json = JSON.parse response.body
        catch e
            response.jsonError = e.message

    _handleResponse: (requesting, next)->
        requesting.then (response)=>
            if logger?
                if response.body.length > 250
                    logger.info "Received HTTP response: #{response.statusCode} with #{response.body.length} bytes"
                else
                    logger.info "Received HTTP response: #{response.statusCode} - #{response.body}"
            @_attemptJsonParsing response
            if response.statusCode isnt 200
                @onLoginRequired() if response.statusCode is 401
                @_reject response, "HTTP request was not successful: #{response.statusCode}"
            if response.jsonError
                @_reject response, "Response contains malformed JSON: "

            if response.headers['set-cookie']
                for cookieLine in response.headers['set-cookie']
                    [name, value] = cookieLine.split(';')[0].split('=')
                    if name is CraftingGuideClient.SESSION_COOKIE
                        @session = value

            if next? then response = next response
            return response

    _reject: (response, message)->
        e = new Error "#{message} #{response.body}"
        e.response = response
        throw e

    _sendRequest: (method, url, data={})->
        if not typeof(method) is 'function' then throw new Error 'method must be a function'
        if not typeof(url) is 'string' then throw new Error 'url must be a string'

        url = "#{@baseUrl}#{url}"
        data.headers ?= {}
        data.headers[key] ?= value for key, value of @_headers
        if @session?
            data.headers['cookie'] = "#{CraftingGuideClient.SESSION_COOKIE}=#{@session}"

        @_handleResponse method url, data

    _setStatus: (newStatus)->
        oldStatus = @_status
        return if newStatus is oldStatus

        @_status = newStatus
        @_lastStatusTime = Date.now()
        @onStatusChanged.call null, this, oldStatus, newStatus
