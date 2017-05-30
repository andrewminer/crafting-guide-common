#
# Crafting Guide Common - constants.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_ = require "./underscore"

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

exports.limits = limits = {}
limits.maximumGraphSize = 5000
limits.maximumPlanCount = 5000

exports.modelState  = modelState = {}
modelState.unloaded = 'unloaded'
modelState.loading  = 'loading'
modelState.loaded   = 'loaded'
modelState.failed   = 'failed'

exports.modPacks = modPacks = {}
modPacks.default = "crafting-guide"

exports.requiredMods = [ 'minecraft' ]

exports.url          = url = {}
url.crafting         = _.template "/craft/<%= inventoryText %>"
url.item             = _.template "/browse/<%= modSlug %>/<%= itemSlug %>/"
url.itemData         = _.template "/data/<%= modSlug %>/items/<%= itemSlug %>/item.cg"
url.itemIcon         = _.template "/data/<%= modSlug %>/items/<%= itemSlug %>/icon.png"
url.itemImageDir     = _.template "/data/<%= modSlug %>/items/<%= itemSlug %>"
url.login            = _.template "/login"
url.mod              = _.template "/browse/<%= modSlug %>/"
url.modData          = _.template "/data/<%= modSlug %>/mod.cg"
url.modIcon          = _.template "/data/<%= modSlug %>/icon.png"
url.modPackArchiveCG = _.template "/data/modpack.cg"
url.modPackArchiveJS = _.template "/data/modpacks/<%= modPackId %>.json"
url.modVersionData   = _.template "/data/<%= modSlug %>/versions/<%= modVersion %>/mod-version.cg"
url.root             = _.template "/"
url.tutorial         = _.template "/browse/<%= modSlug %>/tutorials/<%= tutorialSlug %>/"
url.tutorialData     = _.template "/data/<%= modSlug %>/tutorials/<%= tutorialSlug %>/tutorial.cg"
url.tutorialIcon     = _.template "/data/<%= modSlug %>/tutorials/<%= tutorialSlug %>/icon.png"
url.tutorialIcon     = _.template "/data/<%= modSlug %>/tutorials/<%= tutorialSlug %>/icon.png"
url.tutorialImageDir = _.template "/data/<%= modSlug %>/tutorials/<%= tutorialSlug %>"
