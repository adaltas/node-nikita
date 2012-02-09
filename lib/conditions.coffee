
path = require 'path'
each = require 'each'

###
Conditionnal properties
###
module.exports = 
    ###

    `all(options, failed, succeed)`: Run all conditions
    ---------------------------------------------------

    `opts`
    Command options

    `failed`
    Failed callback, called when a condition failed

    `succeed`
    Succeed callback, only called if all the condition succeed

    ###
    all: (options, failed, succeed) ->
        each([@if_exists, @not_if_exists])
        .on 'item', (next, condition) ->
            condition(options, failed, next)
        .on('error', failed)
        .on('end', succeed)
    ###
    
    `if_exists`: Run action if a file exists
    ----------------------------------------

    Search for the property `if_exists` in `options` or called succeed if not present.

    ###
    if_exists: (options, failed, succeed) ->
        return succeed() unless options.if_exists?
        path.exists options.if_exists, (exists) ->
            if exists
            then succeed()
            else failed()
    ###
    `not_if_exists`: Skip action if a file exists
    ---------------------------------------------

    Search for the property `not_if_exists` in `options` or called succeed if not present.

    ###
    not_if_exists: (options, failed, succeed) ->
        return succeed() unless options.not_if_exists?
        path.exists options.not_if_exists, (exists) ->
            if exists
            then failed()
            else succeed()
