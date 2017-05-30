#
# Crafting Guide Common - http.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_           = require '../underscore'
http        = require 'http'
https       = require 'https'
querystring = require 'querystring'
urlParser   = require 'url'
w           = require 'when'

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

    options.protocol        = url.protocol
    options.method          = method
    options.hostname        = url.hostname or 'localhost'
    options.port            = url.port or (if url.protocol is 'https:' then 443 else 80)
    options.headers         = headers
    options.path            = url.path
    options.withCredentials = true

    urlText = "#{options.method} #{options.protocol}//#{options.hostname}:#{options.port}#{options.path}"

    if logger?
        message = ["Sending HTTP request: "]
        message.push urlText
        if options.headers?
            message.push " with headers: #{_.pp(headers)}"
        if requestBody?
            if requestBody.length > 250
                message.push " with body of #{requestBody.length} bytes"
            else
                message.push " with body: #{requestBody}"

        logger.info message.join ''

    httpLib = if options.protocol is 'https:' then https else http
    startTime = Date.now()
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

                if logger?
                    message = ""
                    if result.body.length < 250
                        message += "Received HTTP response for #{urlText}: #{result.statusCode} - #{result.body}"
                    else
                        bytes = result.body.length

                        if bytes < 1000
                            size = "#{bytes} B"
                        else if bytes < 1000 * 1000
                            size = "#{(bytes / 1000).toFixed(2)} kB"
                        else
                            size = "#{(bytes / 1000 / 1000).toFixed(2)} mB"

                    if result.body.length > 250
                        message += "Received HTTP response for #{urlText}: #{result.statusCode} " +
                            "with #{size}"
                    else

                    message += " after #{Date.now() - startTime}ms"
                logger.info message

        request.on 'error', (e)->
            logger.error "connection failed: #{e.stack}" if logger?
            reject e

        if requestBody?
            request.write requestBody
        request.end()

    return promise
