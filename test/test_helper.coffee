###
Crafting Guide Common - test_helper.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

require 'when/monitor/console'

chai = require 'chai'
chai.use require 'sinon-chai'

########################################################################################################################

chai.config.includeStack = true

global._      = require 'underscore'
global.assert = chai.assert
global.expect = chai.expect
global.should = chai.should()
global.util   = require 'util'
