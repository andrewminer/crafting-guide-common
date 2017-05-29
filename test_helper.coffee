#
# Crafting Guide Common - test_helper.coffee
#
# Copyright (c) 2015 by Redwood Labs
# All rights reserved.
#

require 'when/monitor/console'

chai      = require 'chai'
Logger    = require './src/util/logger'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
util      = require 'util'

########################################################################################################################

chai.config.includeStack = true
chai.use sinonChai

global.assert = chai.assert
global.expect = chai.expect
global.logger = new Logger level:Logger.FATAL
global.should = chai.should()
global.sinon  = sinon
global.util   = util
