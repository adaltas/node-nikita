
path = require 'path'
each = require 'each'

###
Conditionnal properties
###
module.exports = 
    ###

    `all(options, failed, succeed)` Run all conditions
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
    `if` Run action for a user defined condition
    --------------------------------------------

    When `if` is a boolean, its value determine to the output. If it's 
    a callback, the function is called with the `options`, 
    `failed` and `succeed` arguments. If it'a an array, all its element
    must positively resolve for the condition to pass.

    Updating the content of a file if we are the owner
        mecano.render
            source:'./file'
            if: (options, failed, succeed) ->
                fs.stat options.source, (err, stat) ->
                    # File does not exists
                    return failed err if err
                    # Failed if we dont own the file
                    retur  failed() unless stat.uid is process.getuid()
                    # Succeed if we own the file
                    succeed()

    ###
    if: (options, failed, succeed) ->
        si = options.if
        return succeed() unless si?
        si = options.if = [si] unless Array.isArray si
        ok = true
        each(options.if)
        .on 'item', (next, si) ->
            return next() unless ok
            if typeof si is 'boolean'
                ok = false unless si
                next()
            else if typeof si is 'function'
                si options, ( -> ok = false; next arguments...), next
        .on 'both', (err) ->
            if err or not ok
            then failed err
            else succeed()
    ###
    
    `if_exists` Run action if a file exists
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
    `not_if_exists` Skip action if a file exists
    ---------------------------------------------

    Search for the property `not_if_exists` in `options` or called succeed if not present.

    ###
    not_if_exists: (options, failed, succeed) ->
        return succeed() unless options.not_if_exists?
        path.exists options.not_if_exists, (exists) ->
            if exists
            then failed()
            else succeed()
