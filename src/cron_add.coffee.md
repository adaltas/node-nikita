
# `krb5_principal(options, callback)`

Create a new Kerberos principal with a password or an optional keytab.

## Options

*   `user` (name | uid)
    the user of the crontab. the SSH user by default
*   `when` (string)
    cron-styled time string. Defines the frequency of the cron job
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
      return callback new Error 'valid when is required' unless options.when?.length > 0
      return callback new Error 'valid cmd is required' unless options.cmd?.length > 0
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
        myjob = "#{options.when} #{options.cmd}"
        jobs = stdout.trim().split '\n'
        # remove useless last element
        regex = new RegExp ".* #{options.cmd}"
        for job in jobs
          if myjob is job
            options.log? "Job is found in crontab, skipping [INFO]"
            return jobs = null
          if regex.test job
            options.log? "Job is found in crontab, but frequency doesn't match. Updating [WARN]"
            job = myjob
            return
        options.log? "Job not found in crontab. Adding [WARN]"
        jobs.push myjob
      .then (err) ->
        return callback err if err
        return callback() unless jobs
        @
        .execute
          cmd: """
          #{crontab} - <<EOF
          #{jobs.join '\n'}
          EOF
          """
        .execute
          cmd: if options.user? then "su -l #{options.user} -c '#{options.cmd}'" else options.cmd
          if: options.exec
        .then callback

## Dependencies

    wrap = require './misc/wrap'
    execute = require './execute'
