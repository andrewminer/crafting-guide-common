#
# Crafting Guide - mod_vote.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

_ = require 'underscore'

########################################################################################################################

module.exports = (JSData)->

    ModVote = JSData.defineResource

        name: 'ModVote'

        table: 'ModVotes'

        fields: [
            'id'
            'modId'
            'userId'

            'createdAt'
            'updatedAt'
        ]

        methods:

            toHash: ->
                _.pick this, ModVote.fields

        relations:

            belongsTo:
                Mod:
                    localField: 'mod'
                    localKey:   'modId'
                    foreignKey: 'id'
                User:
                    localField: 'user'
                    localKey:   'userId'
                    foreignKey: 'id'
