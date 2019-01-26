
# `nikita.cron.add`

Register a job on crontab.

## Options

* `user` (name | uid)   
  the user of the crontab. the SSH user by default   
* `match` (null | string | regexp).   
  The cron entry to match, a string will be converted to a regexp and an
  undefined or null value will match the exact command.   
* `when` (string)   
  cron-styled time string. Defines the frequency of the cron job.   
* `cmd`   
  the shell command of the job   
* `exec`   
  if true, then cmd will be executed just after if added to crontab   
* `log`   
  Function called with a log related messages.   
* `ssh` (object|ssh2)   
  Run the action on a remote server using SSH, an ssh2 instance or an
  configuration object used to initialize the SSH connection.   
* `stdout` (stream.Writable)   
  Writable EventEmitter in which the standard output of executed commands will
  be piped.   
* `stderr` (stream.Writable)   
  Writable EventEmitter in which the standard error output of executed command
  will be piped.   

## Example

```js
require('nikita').cron.add({
  cmd: 'kinit service/my.fqdn@MY.REALM -kt /etc/security/service.keytab',
  when: '0 */9 * * *'
  user: 'service'
}, function(err, status){
  console.log(err ? err.message : 'Cron entry created or modified: ' + status);
});
```

## Source Code

    module.exports = ({options}, callback) ->
      return callback Error 'valid when is required' unless options.when and typeof options.when is 'string'
      return callback Error 'valid cmd is required' unless options.cmd
      if options.user?
        @log message: "Using user #{options.user}", level: 'DEBUG', module: 'nikita/cron/add'
        crontab = "crontab -u #{options.user}"
      else
        @log message: "Using default user", level: 'DEBUG', module: 'nikita/cron/add'
        crontab = "crontab"
      jobs = null
      @system.execute
        cmd: "#{crontab} -l"
        code: [0, 1]
      , (err, {stdout, stderr}) ->
        throw err if err and not /^no crontab for/.test stderr
        # throw Error 'User crontab not found' if /^no crontab for/.test stderr
        new_job = "#{options.when} #{options.cmd}"
        # remove useless last element
        regex =
          unless options.match then new RegExp ".* #{regexp.escape options.cmd}"
          else if typeof options.match is 'string' then new RegExp options.match
          else if util.isRegExp options.match then options.match
          else throw Error "Invalid option 'match'"
        added = true
        jobs = for job, i in string.lines stdout.trim()
          if regex.test job
            added = false
            break if job is new_job # Found job, stop here
            @log message: "Entry has changed", level: 'WARN', module: 'nikita/cron/add'
            diff job, new_job, options
            job = new_job
            modified = true
          job
        if added
          jobs.push new_job
          @log message: "Job not found in crontab, adding", level: 'WARN', module: 'nikita/cron/add'
        jobs = null unless added or modified
      .next (err) ->
        return callback err if err
        return callback() unless jobs
        @system.execute
          cmd: if options.user? then "su -l #{options.user} -c '#{options.cmd}'" else options.cmd
          if: options.exec
        @system.execute
          cmd: """
          #{crontab} - <<EOF
          #{jobs.join '\n'}
          EOF
          """
        .next callback

## Dependencies

    util = require 'util'
    {regexp} = require '../misc'
    diff = require '../misc/diff'
    string = require '../misc/string'
    wrap = require '../misc/wrap'
