#
# Crafting Guide Common - mod.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_ = require 'underscore'

########################################################################################################################

module.exports = (JSData)->

    Mod = JSData.defineResource

        name: 'Mod'

        table: 'Mods'

        fields: [
            'id'
            'name'
            'url'

            'createdAt'
            'updatedAt'
        ]

        methods:

            toHash: ->
                _.pick this, Mod.fields

        relations:

            hasMany:
                ModVote:
                    localField: 'votes'
                    localKey:   'id'
                    foreignKey: 'modId'
