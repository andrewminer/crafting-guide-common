#
# Crafting Guide - user.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_ = require 'underscore'

########################################################################################################################

module.exports = (JSData)->

    User = JSData.defineResource

        name: 'User'

        table: 'Users'

        fields: [
            'id'
            'avatarUrl'
            'email'
            'gitHubAccessToken'
            'gitHubId'
            'gitHubLogin'
            'name'

            'createdAt'
            'updatedAt'
        ]

        methods:

            copyGitHubUser: (gitHubUser)->
                @avatarUrl   = gitHubUser.avatar_url
                @email       = gitHubUser.email
                @gitHubId    = gitHubUser.id
                @gitHubLogin = gitHubUser.login
                @name        = gitHubUser.name

            toJSON: ->
                _.pick this, User.fields

        relations:

            hasMany:
                ModVote:
                    localField: 'votes'
                    localKey:   'id'
                    foreignKey: 'userId'
