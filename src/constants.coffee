#
# Crafting Guide Common - constants.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

exports.event         = event = {}
event.add             = 'add'                 # collection, item...
event.button          = {}
event.button.complete = 'button:complete'     # controller
event.button.first    = 'button:first'        # controller, buttonType
event.button.second   = 'button:second'       # controller, buttonType
event.change          = 'change'              # model
event.click           = 'click'               # event
event.load            = {}
event.load.started    = 'load:started'        # controller, url
event.load.succeeded  = 'load:succeeded'      # controller, book
event.load.failed     = 'load:failed'         # controller, error message
event.load.finished   = 'load:finished'       # controller
event.remove          = 'remove'              # collection, item...
event.request         = 'request'             # model
event.route           = 'route'
event.sort            = 'sort'
event.sync            = 'sync'                # model, response

exports.modelState  = modelState = {}
modelState.unloaded = 'unloaded'
modelState.loading  = 'loading'
modelState.loaded   = 'loaded'
modelState.failed   = 'failed'
