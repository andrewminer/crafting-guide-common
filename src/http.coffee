###
Crafting Guide Common - http.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

_           = require 'underscore'
http        = require 'http'
https       = require 'https'
querystring = require 'querystring'
urlParser   = require 'url'
w           = require 'when'

_.mixin require './string_mixins'

# Client Methods #######################################################################################################

module.exports.get = (url, options={})-> sendRequest 'GET', url, options

module.exports.post = (url, options={})-> sendRequest 'POST', url, options

module.exports.put = (url, options={})-> sendRequest 'PUT', url, options

module.exports.delete = (url, options={})-> sendRequest 'DELETE', url, options

# Private ##############################################################################################################

sendRequest = (method, url, options={})->
    url = urlParser.parse url

    headers = {}
    if options.headers?
        headers = options.headers

    if options.body?
        if typeof(options.body) is 'string'
            requestBody = options.body
            options.contentType ?= 'text/plain'
            headers['content-type'] = options.contentType
        else
            if method is 'GET'
                url.path += "?#{querystring.stringify(options.body)}"
            else if method in ['POST', 'PUT']
                requestBody = JSON.stringify options.body
                options.contentType ?= 'application/json'
                headers['content-type'] = options.contentType

    options.protocol = url.protocol
    options.method   = method
    options.hostname = url.hostname or 'localhost'
    options.port     = url.port or (if url.protocol is 'http' then 80 else 443)
    options.headers  = headers
    options.path     = url.path

    if logger?
        message = ["Sending HTTP request: "]
        message.push "#{options.method} #{options.protocol}//#{options.hostname}:#{options.port}#{options.path}"
        if options.headers?
            message.push " with headers: #{_.pp(headers)}"
        if requestBody?
            message.push " with body: #{requestBody}"

        logger.info message.join ''

    httpLib = if options.protocol is 'https:' then https else http
    promise = w.promise (resolve, reject)->
        request = httpLib.request options, (response)->
            if not response?
                reject new Error 'No response'
                return

            result = {statusCode: response.statusCode, headers:response.headers}
            buffer = []
            response.on 'data', (data)-> buffer.push data
            response.on 'error', (e)-> reject e
            response.on 'end', ->
                result.body = buffer.join ''
                resolve result

        request.on 'error', (e)->
            logger.error "connection failed: #{e.stack}" if logger?
            reject e

        if requestBody?
            request.write requestBody
        request.end()

    return promise
