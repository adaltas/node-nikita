
# `cron_delete(options, callback)`

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
require('mecano').cron_delete({
  cmd: 'kinit service/my.fqdn@MY.REALM -kt /etc/security/service.keytab',
  when: '0 */9 * * *'
  user: 'service'
}, function(err, modified){
  console.log(err ? err.message : 'Cron entry created or modified: ' + !!modified);
});
```

## Source Code

    escape = (str) -> str.replace /[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"

    module.exports = (options, callback) ->
      wrap @, arguments, (options, callback) ->
        return callback new Error 'valid cmd is required' unless options.cmd?.length > 0
        if options.user?
          options.log? "Using user #{options.user} [INFO]"
          crontab = "crontab -u #{options.user}"
        else
          options.log? 'Using default user [INFO]'
          crontab = "crontab"
        modified = false
        do_list = ->
          execute
            cmd: "#{crontab} -l"
            ssh: options.ssh
            log: options.log
            stdout: options.stdout
            stderr: options.stderr
          , (err, _, stdout, stderr) ->
            return callback err if err and not /^no crontab for/.test stderr
            return next err if err
            myjob = if options.when then escape options.when else '.*'
            myjob += escape " #{options.cmd}"
            regex = new RegExp myjob
            jobs = stdout.split '\n'
            # remove useless last element
            jobs.pop()
            for job, i in jobs
              if regex.test job
                options.log? "Job '#{job}' matches. Removing from list [WARN]"
                modified = true
                jobs.splice i, 1
            return do_write jobs
        do_write = (jobs) ->
          unless modified
            options.log? 'No Job matches. Skipping [INFO]'
            return callback null, false unless modified
          execute
            cmd: "echo -e '#{jobs.join '\\n'}' | #{crontab} -"
            ssh: options.ssh
            log: options.log
            stdout: options.stdout
            stderr: options.stderr
          , callback
        do_list()

## Dependencies

    wrap = require './misc/wrap'
    execute = require './execute'
