###
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

_ = require 'underscore'
_.mixin require '../src/string_mixins'

########################################################################################################################

describe 'ellipsize', ->

    it "doesn't change a short string", ->
        _.ellipsize('foobar', 10).should.equal 'foobar'

    it 'properly handles a solid chunk of characters', ->
        _.ellipsize('abcdefghijklmnopqrstuvwxyz', 10).should.equal 'abcdefg...'

    it 'property trims at word boundaries', ->
        _.ellipsize('alpha bravo charlie delta echo foxtrot', 23).should.equal 'alpha bravo charlie...'

    it 'works with punctuation', ->
        _.ellipsize('alpha, bravo, charlie, delta, and echo', 26).should.equal 'alpha, bravo, charlie...'

    it "doesn't trim too much with really long words", ->
        _.ellipsize('alpha bravo charliedeltaechofoxtrot', 30).should.equal 'alpha bravo charliedeltaech...'

describe 'encodeId', ->

    it 'works with lower order bytes', ->
        buffer = new Buffer [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        _.encodeId(buffer).should.equal 'ABCDEFGHIJKLMNOP'

    it 'works with high order bytes', ->
        buffer = new Buffer [64, 65, 66, 67, 68, 69, 70, 71]
        _.encodeId(buffer).should.equal '.~ECEDEEEFEGEH'

    it 'works with mixed high and low', ->
        buffer = new Buffer [0, 64, 1, 65, 2, 66, 3, 67, 4, 68, 5]
        _.encodeId(buffer).should.equal 'A.B~CECDEDEEEF'

describe 'leftPad', ->

    it 'works with a short string', ->
        _.leftPad('abc', 10).should.equal '       abc'

    it 'works with a long string', ->
        _.leftPad('abcdefghij', 10).should.equal 'abcdefghij'

    it 'works with an empty string', ->
        _.leftPad('', 10).should.equal '          '

    it 'works with an alternate pad string', ->
        _.leftPad('abc', 10, '.').should.equal '.......abc'

    it 'handles null values', ->
        _.leftPad(null, 10).should.equal '      null'

describe 'print', ->

    it 'returns the correct value for undefined and null', ->
        _.print(undefined).should.equal 'undefined'
        _.print(null).should.equal 'null'

    it 'returns a string unchanged', ->
        _.print('alpha').should.equal 'alpha'

    it 'obeys a custom "toString" function', ->
        _.print(new TestObject('a', 'b', 'fred')).should.equal "I have a and b"

    it 'correctly identifies an array', ->
        _.print(['alpha', 'bravo']).should.equal '[alpha, bravo]'

    it 'correctly identifies a function', ->
        _.print(sampleFunction).should.equal 'function () { var alpha, bravo, charlie, delta...'

    it 'correctly identifies an object with a constructor', ->
        _.print(new TestObjectWithoutToString('c', 'd', 'fred')).should
            .equal "TestObjectWithoutToString<fred>{charlie:c, delta:d}"

    it 'treats unidentified things as a hash', ->
        _.print({alpha:1, bravo:2}).should.equal "{alpha:1, bravo:2}"


describe 'printArray', ->

    it 'returns a string when no array is given', ->
        _.printArray(['alpha', 'bravo']).should.equal '[alpha, bravo]'

    it 'appends to a given array', ->
        result = ['alpha']
        newResult = _.printArray ['bravo', 'charlie'], result:result
        newResult.should.eql result
        newResult.should.eql ['alpha', '[', 'bravo', ', ', 'charlie', ']']

    it 'works with an empty list', ->
        _.printArray([]).should.equal '[]'

describe 'printElements', ->

    it 'returns a string when no array is given', ->
        _.printElements(['alpha', 'bravo']).should.equal "alpha, bravo"

    it 'appends to the given array', ->
        result = ['alpha']
        newResult = _.printElements ['bravo', 'charlie'], result:result
        newResult.should.eql result
        newResult.should.eql ['alpha', 'bravo', ', ', 'charlie']

    it 'works with an empty list', ->
        _.printElements([]).should.equal ''

describe 'printHash', ->

    it 'wraps the property list correctly', ->
        _.printHash({alpha:'a', bravo:42}).should.equal '{alpha:a, bravo:42}'

    it 'avoids cycles', ->
        a = name:'a'
        b = name:'b', alpha:a
        c = name:'c', bravo:b
        a.charlie = c

        _.printHash(a).should.equal '{charlie:{bravo:{alpha:{...}, name:b}, name:c}, name:a}'

    it 'allows duplicates', ->
        a = name:'a'
        b = name:'b'
        c = a:a, a2:a, b:b, b2:b

        _.printHash(c).should.equal '{a:{name:a}, a2:{name:a}, b:{name:b}, b2:{name:b}}'

describe 'printObject', ->

    it 'correctly shows the class name', ->
        _.printObject(new TestObject('a', 'b', 'fred')).should.equal "TestObject<fred>{alpha:a, bravo:b}"

describe 'printProperties', ->

    it 'returns a string when no array given', ->
        _.printProperties({alpha:'a', bravo:'b'}).should.equal 'alpha:a, bravo:b'

    it 'appends to the given array', ->
        result = ['alpha', ':', 'a']
        newResult = _.printProperties({bravo:'b', charlie:'c'}, result:result)
        newResult.should.eql result
        newResult.should.eql ['alpha', ':', 'a', 'bravo', ':', 'b', ', ', 'charlie', ':', 'c']

    it 'works with an empty object', ->
        _.printProperties({}).should.eql ''

    it 'only displays public, enumerable properties', ->

        obj = alpha: 'a'
        Object.defineProperty obj, '_bravo', value:'b'

        _.printProperties(obj).should.equal "alpha:a"

describe 'rightPad', ->

    it 'works with a short string', ->
        _.rightPad('abc', 10).should.equal 'abc       '

    it 'works with a long string', ->
        _.rightPad('abcdefghij', 10).should.equal 'abcdefghij'

    it 'works with an empty string', ->
        _.rightPad('', 10).should.equal '          '

    it 'works with an alternate pad string', ->
        _.rightPad('abc', 10, '.').should.equal 'abc.......'

    it 'handles null values', ->
        _.rightPad(null, 10).should.equal 'null      '

# Helpers ##############################################################################################################

class TestObject

    constructor: (alpha, bravo, name)->
        @alpha = alpha
        @bravo = bravo
        @name  = name

    toString: -> "I have #{@alpha} and #{@bravo}"

class TestObjectWithoutToString

    constructor: (@charlie, @delta, @name)->

sampleFunction = ->
    alpha = 1; bravo = 2; charlie = 3; delta = 4; echo = 5; foxtrot = 6
