###
Crafting Guide Common - string_mixins.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

_    = require 'underscore'
uuid = require 'uuid'

########################################################################################################################

exports.ellipsize = ellipsize = (s, length=25)->
    ellipsis = '...'
    wordSearchBuffer = 10

    throw new Error("length (#{length}) must be at least #{ellipsis.length}") if length < ellipsis.length
    return s if s.length < length

    foundWordBreak = false
    startIndex = length - ellipsis.length
    endIndex = Math.max(0, (length - ellipsis.length - wordSearchBuffer))

    # Let's see if we can find a nice word boundary without removing too much.
    result = null
    for i in [startIndex..endIndex]
        isWordChar = s.charAt(i).match(/\w/)
        if foundWordBreak and isWordChar
            result = "#{s.slice(0, i+1)}#{ellipsis}"
            break
        else if not isWordChar
            foundWordBreak = true

    # We didn't find a word boundary, so just truncate normally
    result = "#{s.slice(0, length-ellipsis.length)}#{ellipsis}" if not result?

    return result

exports.encodeId = (buffer)->
    DOMAIN = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~'
    letters = []
    for b in buffer
        if b < DOMAIN.length
            letters.push DOMAIN[b]
        else
            letters.push DOMAIN[b >>> 4]
            letters.push DOMAIN[b & 0x0F]
    return letters.join ''

exports.leftPad = (string, desiredLength=0, padString=' ')->
    string = "#{string}"
    throw new Error "#{string} must have a `length`" unless string?.length?
    throw new Error 'padString.length must be > 0' unless padString.length > 0

    result = []
    length = string.length
    while length < desiredLength
        result.push padString
        length += padString.length
    result.push string
    return result.join ''

exports.rightPad = (string, desiredLength=0, padString=' ')->
    string = "#{string}"
    throw new Error "#{string} must have a `length`" unless string?.length?
    throw new Error 'padString.length must be > 0' unless padString.length > 0

    result = [string]
    length = string.length
    while length < desiredLength
        result.push padString
        length += padString.length
    return result.join ''

exports.uuid = ->
    buffer = uuid.v4(null, new Buffer(16))
    exports.encodeId buffer

# Object Printing ######################################################################################################

_wrapper = (f, obj, args={})->
    return 'undefined' if obj is undefined
    return 'null' if obj is null

    joinResult = not args.result?
    args.result ?= []

    f obj, args.result, args

    return if joinResult then args.result.join('') else args.result

exports.print = exports.pp = print = (obj, result, args={})->
    if not obj?
        result.push "#{obj}"
    else if _.isString obj
        result.push obj
    else if _.isArray obj
        printArray obj, result, args
    else if _.isFunction obj
        text = obj.toString().replace(new RegExp('[\\r\\n]+', 'gm'), ' ').replace(new RegExp('\\s+', 'gm'), ' ')
        result.push ellipsize text, 50
    else if obj.toString isnt Object::toString
        result.push obj.toString()
    else if obj.constructor?.name? and obj.constructor.name isnt 'Object'
        printObject obj, result, args
    else
        printHash obj, result, args

exports.printArray = printArray = (obj, result, args={})->
    result.push '['
    printElements obj, result, args
    result.push ']'

exports.printElements = printElements = (obj, result, args={})->
    needsDelimiter = false
    for e in obj
        if needsDelimiter then result.push ', '
        needsDelimiter = true
        print e, result, args

exports.printHash = printHash = (obj, result, args={})->
    args.hasSeen ?= []
    for other in args.hasSeen
        if obj is other
            result.push '{...}'
            return

    args.hasSeen.push obj

    result.push '{'
    printProperties obj, result, args
    result.push '}'

    args.hasSeen.pop()

exports.printObject = printObject = (obj, result, args={})->
    args.exclude ?= []
    description = null

    descriptionProperty = null
    for property in ['name', 'id']
        if obj[property]?
            descriptionProperty = property

    if descriptionProperty?
        args.exclude.push descriptionProperty
        description = obj[descriptionProperty]

    result.push obj.constructor.name
    if description?
        result.push '<'
        result.push description
        result.push '>'

    if not args.brief
        printHash obj, result, args

exports.printProperties = printProperties = (obj, result, args={})->
    needsDelimiter = false
    for name in _.keys(obj).sort()
        if not args.exclude or not (name in args.exclude)
            if needsDelimiter then result.push ', '
            needsDelimiter = true
            result.push name
            result.push ':'
            try
                print obj[name], result, args
            catch e
                result.push e

for name in ['pp', 'print', 'printArray', 'printHash', 'printElements', 'printObject', 'printProperties']
    exports[name] = ((f)-> return (o, a={})-> _wrapper(f, o, a))(exports[name])
