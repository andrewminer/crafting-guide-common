###
Crafting Guide Common - crafting_guide_client.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

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
        options.baseUrl         ?= 'http://localhost:8000'
        options.headers         ?= {}
        options.onStatusChanged ?= (client, oldStatus, newStatus)-> # do nothing
        options.onLoginRequired ?= (client)-> # do nothing

        @baseUrl         = options.baseUrl
        @onStatusChanged = options.onStatusChanged
        @onLoginRequired = options.onLoginRequired

        @_headers        = options.headers
        @_sessionCookie  = null
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

    reset: ->
        @_sessionCookie = null

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
        status: {get:@prototype.getStatus}

    # Request Methods ##############################################################################

    completeGitHubLogin: (args={})->
        return w.reject new Error 'args.code is required' unless args.code
        @_sendRequest http.post, '/github/complete-login', body:args

    fetchCurrentUser: ->
        @_sendRequest http.get, '/github/user'

    fetchFile: (args={})->
        return w.reject new Error 'args.file is required' unless args.file
        args.file = args.file.substring(1) if args.file[0] is '/'
        @_sendRequest http.get, "/github/file/#{args.file}"

    logout: ->
        @_sendRequest http.delete, '/github/logout'

    ping: (args={})->
        return w.reject new Error 'args.message is required' unless args.message
        @_sendRequest http.get, '/ping', body:args

    # Private Methods ##############################################################################

    _attemptJsonParsing: (response)->
        try
            response.json = JSON.parse response.body
            response.json.status  ?= 'success'
            response.json.message ?= 'ok'
            response.json.data    ?= null
        catch e
            response.jsonError = e.message

    _handleResponse: (requesting, next)->
        requesting.then (response)=>
            logger.info "Received HTTP response: #{response.statusCode} #{response.body}" if logger?
            @_attemptJsonParsing response
            if response.statusCode isnt 200
                @onLoginRequired() if response.statusCode is 401
                @_reject response, "HTTP request was not successful: #{response.statusCode}"
            if response.jsonError
                @_reject response, "Response contains malformed JSON: "
            if response.json.status isnt 'success'
                @_reject response, "API request was unsuccessful: "

            if response.headers['set-cookie']
                for cookieLine in response.headers['set-cookie']
                    [name, value] = cookieLine.split(';')[0].split('=')
                    if name is CraftingGuideClient.SESSION_COOKIE
                        @_sessionCookie = value

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
        if @_sessionCookie?
            data.headers['cookie'] = "#{CraftingGuideClient.SESSION_COOKIE}=#{@_sessionCookie}"

        @_handleResponse method url, data

    _setStatus: (newStatus)->
        oldStatus = @_status
        return if newStatus is oldStatus

        @_status = newStatus
        @_lastStatusTime = Date.now()
        @onStatusChanged.call null, this, oldStatus, newStatus
