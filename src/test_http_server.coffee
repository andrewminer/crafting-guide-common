###
Crafting Guide Common - test_http_server.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

http = require 'http'

########################################################################################################################

module.exports = class TestHttpServer

    constructor: (@port)->
        @requests = []
        @responses = []

    clear: ->
        @requests = []
        @responses = []

    start: ->
        @server = http.createServer ((o)-> return (q, s)-> o.onRequest(q, s))(this)

        deferred = w.defer()
        @server.listen @port, =>
            deferred.resolve this
        return deferred.promise

    stop: ->
        w.promise (resolve, reject)=>
            if not @server then return w(this)
            @server.close (isError)-> if isError then reject(this) else resolve(this)

    onRequest: (request, response)->
        data =
            method:  request.method
            url:     request.url
            headers: request.headers
            path:    request.path
            body:    []
            error:   null

        data.reading = w.promise (resolve, reject)->
            request.on 'data', (text)->
                data.body.push text
            request.on 'error', (e)->
                data.error = e
                reject e
            request.on 'end', ->
                data.body = data.body.join ''
                delete data.reading
                resolve data

        @requests.push data

        data.reading.then =>
            next = @responses.shift()
            if not next? then next = {statusCode:500, headers:{}, body:'Out of responses'}

            if typeof next is 'function'
                next request, response
            else
                response.statusCode = next.statusCode
                for name, value in next.headers
                    response.setHeader name, value
                response.write next.body if next.body?

            response.end()

    pushResponse: (args)->
        if typeof args is 'function'
            @responses.push args
        else
            args.statusCode ?= 500
            args.body       ?= ''
            args.headers    ?= {}

            @responses.push {statusCode:args.statusCode, headers:args.headers, body:args.body}