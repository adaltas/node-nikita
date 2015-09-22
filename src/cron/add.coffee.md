
# `krb5_principal(options, callback)`

Create a new Kerberos principal with a password or an optional keytab.

## Options

*   `user` (name | uid)   
    the user of the crontab. the SSH user by default   
*   `match` (null | string | regexp).   
    The cron entry to match, a string will be converted to a regexp and an
    undefined or null value will match the exact command.   
*   `when` (string)   
    cron-styled time string. Defines the frequency of the cron job.   
*   `cmd`   
    the shell command of the job   
*   `exec`   
    if true, then cmd will be executed just after if added to crontab   
*   `log`   
    Function called with a log related messages.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   

## Example

```js
require('mecano').cron_add({
  cmd: 'kinit service/my.fqdn@MY.REALM -kt /etc/security/service.keytab',
  when: '0 */9 * * *'
  user: 'service'
}, function(err, modified){
  console.log(err ? err.message : 'Cron entry created or modified: ' + !!modified);
});
```

## Source Code

    module.exports = (options, callback) ->
      return callback new Error 'valid when is required' unless options.when
      return callback new Error 'valid cmd is required' unless options.cmd
      if options.user?
        options.log? "Using user #{options.user} [DEBUG]"
        crontab = "crontab -u #{options.user}"
      else
        options.log? 'Using default user [DEBUG]'
        crontab = "crontab"
      jobs = null
      @
      .execute
        cmd: "#{crontab} -l"
        code: [0, 1]
      , (err, _, stdout, stderr) ->
        throw err if err and not /^no crontab for/.test stderr
        # throw Error 'User crontab not found' if /^no crontab for/.test stderr
        new_job = "#{options.when} #{options.cmd}"
        # remove useless last element
        regex =
          unless options.match then new RegExp ".* #{options.cmd}"
          else if typeof options.match is 'string' then new RegExp options.match
          else if util.isRegExp options.match then options.match
          else throw Error "Invalid option 'match'"
        added = true
        jobs = for job, i in string.lines stdout.trim()
          # console.log job, regex.test job
          if regex.test job
            added = false
            break if job is new_job # Found job, stop here
            options.log? "`mecano chron_add`: entry has changed [WARN]"
            diff job, new_job, options
            job = new_job
            modified = true
          job
        if added
          jobs.push new_job
          options.log? "Job not found in crontab. Adding [WARN]"
        jobs = null unless added or modified
      .then (err) ->
        return callback err if err
        return callback() unless jobs
        @
        .execute
          cmd: if options.user? then "su -l #{options.user} -c '#{options.cmd}'" else options.cmd
          if: options.exec
        .execute
          cmd: """
          #{crontab} - <<EOF
          #{jobs.join '\n'}
          EOF
          """
          # if: -> jobs
        .then callback

## Dependencies

    util = require 'util'
    diff = require '../misc/diff'
    string = require '../misc/string'
    wrap = require '../misc/wrap'
