
# `nikita.tools.cron.remove`

Remove job(s) on crontab.

## Options

* `user` (name | uid)   
  the user of the crontab. the SSH user by default   
* `when` (string)   
  cron-styled time string. Defines the frequency of the cron job. By default all
  frequency will match.   
* `cmd`   
  the shell command of the job. By default all jobs will match.   
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
require('nikita').cron.remove({
  cmd: 'kinit service/my.fqdn@MY.REALM -kt /etc/security/service.keytab',
  when: '0 */9 * * *'
  user: 'service'
}, function(err, status){
  console.info(err ? err.message : 'Cron entry created or modified: ' + status);
});
```

## Source Code

    module.exports = ({config}, callback) ->
      return callback Error 'valid cmd is required' unless config.cmd?.length > 0
      if config.user?
        @log message: "Using user #{config.user}", level: 'INFO', module: 'nikita/cron/remove'
        crontab = "crontab -u #{config.user}"
      else
        @log message: "Using default user", level: 'INFO', module: 'nikita/cron/remove'
        crontab = "crontab"
      status = false
      jobs = []
      @execute
        cmd: "#{crontab} -l"
        shy: true
      , (err, {stdout, stderr}) ->
        throw err if err
        throw Error 'User crontab not found' if /^no crontab for/.test stderr
        myjob = if config.when then regexp.escape config.when else '.*'
        myjob += regexp.escape " #{config.cmd}"
        regex = new RegExp myjob
        jobs = stdout.trim().split '\n'
        for job, i in jobs
          continue unless regex.test job
          @log message: "Job '#{job}' matches. Removing from list", level: 'WARN', module: 'nikita/cron/remove'
          status = true
          jobs.splice i, 1
        @log message: "No Job matches. Skipping", level: 'INFO', module: 'nikita/cron/remove'
      .execute
        cmd: """
        #{crontab} - <<EOF
        #{jobs.join '\n'}
        EOF
        """
        if: -> status
      .next callback

## Dependencies

    {regexp} = require '@nikitajs/core/lib/misc'
