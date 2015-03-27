###
Crafting Guide Common - crafting_guide_client.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

http = require './http'

########################################################################################################################

module.exports = class CraftingGuideClient

    @SESSION_COOKIE = 'crafting-guide-session'

    constructor: (options={})->
        @_baseUrl       = options.baseUrl or 'http://localhost:8000'
        @_headers       = options.headers or {}
        @_sessionCookie = null

    # Public Methods ###############################################################################

    reset: ->
        @_sessionCookie = null

    # Request Methods ##############################################################################

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

        url = "#{@_baseUrl}#{url}"
        data.headers ?= {}
        data.headers[key] ?= value for key, value of @_headers
        if @_sessionCookie?
            data.headers['cookie'] = "#{CraftingGuideClient.SESSION_COOKIE}=#{@_sessionCookie}"

        @_handleResponse method url, data
