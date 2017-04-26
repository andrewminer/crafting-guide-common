#
# Crafting Guide Common - mod_ballot.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_ = require 'underscore'

########################################################################################################################

module.exports = (JSData)->

    ModBallot = JSData.defineResource

        name: 'ModBallot'

        table: null

        fields: [
            "id"
        ]

        methods:

            toHash: ->
                hash = _.pick this, ModBallot.fields
                hash.lines = (l.toHash() for l in @lines)
                return hash

        relations:

            hasMany:
                ModBallotLine:
                    localField: 'lines'
                    localKey: 'id'
                    foreignKey: 'ballotId'
