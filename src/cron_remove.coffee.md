
# `cron_remove(options, callback)`

Remove job(s) on crontab.

## Options

*   `user` (name | uid)
    the user of the crontab. the SSH user by default
*   `when` (string)
    cron-styled time string. Defines the frequency of the cron job. By default all
    frequency will match.
*   `cmd`
    the shell command of the job. By default all jobs will match.
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
require('mecano').cron_remove({
  cmd: 'kinit service/my.fqdn@MY.REALM -kt /etc/security/service.keytab',
  when: '0 */9 * * *'
  user: 'service'
}, function(err, status){
  console.log(err ? err.message : 'Cron entry created or modified: ' + !!status);
});
```

## Source Code

    escape = (str) -> str.replace /[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"

    module.exports = (options, callback) ->
      return callback new Error 'valid cmd is required' unless options.cmd?.length > 0
      if options.user?
        options.log? "Using user #{options.user} [INFO]"
        crontab = "crontab -u #{options.user}"
      else
        options.log? 'Using default user [INFO]'
        crontab = "crontab"
      status = false
      jobs = []
      @
      .execute
        cmd: "#{crontab} -l"
        shy: true
      , (err, _, stdout, stderr) ->
        throw err if err
        throw Error 'User crontab not found' if /^no crontab for/.test stderr
        myjob = if options.when then escape options.when else '.*'
        myjob += escape " #{options.cmd}"
        regex = new RegExp myjob
        jobs = stdout.trim().split '\n'
        for job, i in jobs
          continue unless regex.test job
          options.log? "Job '#{job}' matches. Removing from list [WARN]"
          status = true
          jobs.splice i, 1
        options.log? 'No Job matches. Skipping [INFO]' unless status
      .execute
        cmd: """
        #{crontab} - <<EOF
        #{jobs.join '\n'}
        EOF
        """
        if: -> status
      .then callback

## Dependencies

    wrap = require './misc/wrap'
    execute = require './execute'
