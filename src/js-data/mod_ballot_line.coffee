#
# Crafting Guide Common - mod_ballot_line.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_ = require 'underscore'

########################################################################################################################

module.exports = (JSData)->

    ModBallotLine = JSData.defineResource

        name: 'ModBallotLine'

        table: null

        fields: [
            "id"
            "ballotId"
            "modId"
            "name"
            "url"
            "voteCount"
        ]

        methods:

            toHash: ->
                hash = _.pick this, ModBallotLine.fields

        relations:

            belongsTo:
                ModBallot:
                    localField: 'ballot'
                    localKey: 'id'
                    foreignKey: 'ballotId'
