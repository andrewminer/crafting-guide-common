###
Crafting Guide Common - test_helper.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

require 'when/monitor/console'

Logger = require '../src/logger'
chai   = require 'chai'
sinon  = require 'sinon-chai'

########################################################################################################################

chai.config.includeStack = true
chai.use sinon

global._      = require 'underscore'
global.assert = chai.assert
global.expect = chai.expect
global.logger = new Logger level:Logger.DEBUG
global.should = chai.should()
global.util   = require 'util'