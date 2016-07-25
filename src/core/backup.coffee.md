
# `backup(options, callback)`

Commons backup functions provided by backmeup. For additional information, please refer to the [official backmeup webpage][backmeup].

## Backmeup Option properties

*   `name` (string)   
    backup name (MANDATORY)   
    default value: randomly generated   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
    If _null_, backup is run locally   
*   `cmd` (string)      
    execute cmd, the output stream will be backuped. If the cmd cannot be piped to
    the compression algorithm, an error will occur. Ignored if source.   
    default value: _undefined_   
*   `source` (string)   
    file or directory (path) to copy. Error if source and cmd are both _null_ or _undefined_   
    default value: _undefined_   
*   `target` (string)
    where the file or directory is copied. Error if _null_ or _undefined_   
    default value: _undefined_   
*   `filter` (string | array)   
    filter files in source. Accept globbing. Source is treated as a directory if exist   
    default value: _undefined_   
*   `interval` (object | number | string)   
    the minimum interval between two backups. If the actual time is before 
    the last backup plus this duration parameter, backup will be skipped.
    See momentjs duration parameter for possible value.   
*   `archive` (boolean)   
    if _false_, source is copied. If _true_ files are archived (tar).   
    default value: _true_   
*   `algorithm` ('gzip' | 'xz' | 'bunzip2' | 'none')   
    compression algorithm. Ignored if archive is _false_ and source is defined
    default value: if archive _'gzip'_, else _undefined_   
*   `clean_source` (boolean)   
    if _true_, source is deleted after backup.   
    default value: _false_   
*   `ignore_hidden_files` (boolean)   
    if _true_, hidden files are ignored.   
    default value: _false_   
*   `retention` (object)   
    if neither _undefined_ nor _null_, backup.clean will be called. See below
    default value: _undefined_   

## Callback parameters

*   `err` (Error)   
    Error object if any.   
*   `done`  (boolean)   
    If the backup was executed or not.   
*   `info` (object)   
    backup passes options to a callback. Info contains _options_ properties with default
    and/or generated missing values.   

## Example

```js
mecano.backmeup({
  name: 'my_backup'
  ssh: ssh_connect
  source: '/etc'     
  filter: 'myfile' | '*.log' | ['file1, 'file2', 'toto/titi'] 
  target: '/tmp'
  archive: false
  algorithm: 'gzip' | 'bzip2' | 'xz' | 'none'
  extension: 'tgz'
  clean_source: true
  retention: {
    count: 3
    date: '2015-01-01-00:00:00'
    age: month: 2
  }
}, function(err, done, info){
  console.log(info);
});
```

## Source code

    module.exports = (options, callback) ->
      options.log message: "Entering backup", level: 'DEBUG', module: 'mecano/lib/backup'
      backmeup options, callback

## Dependencies

    backmeup = require 'backmeup'

[backmeup]: https://github.com/adaltas/node-backmeup
