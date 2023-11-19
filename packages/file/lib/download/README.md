
# `nikita.file.download`

Download files using various protocols.

In local mode (with an SSH connection), the `http` protocol is handled with the
"request" module when executed locally, the `ftp` protocol is handled with the
"jsftp" and the `file` protocol is handle with the native `fs` module.

The behavior of download may be confusing wether you are running over SSH or
not. Its philosophy mostly rely on the target point of view. When download
run, the target is local, compared to the upload function where target
is remote.

A checksum may provided with the option "sha256", "sha1" or "md5" to validate the uploaded
file signature.

Caching is active if "cache_dir" or "cache_file" are defined to anything but false.
If cache_dir is not a string, default value is `./`. If cache_file is not a
string, default is source basename.

Nikita resolve the path from "cache_dir" to "cache_file", so if cache_file is an
absolute path, "cache_dir" will be ignored

If no cache is used, signature validation is only active if a checksum is
provided.

If cache is used, signature validation is always active, and md5sum is automatically
calculated if neither sha256, sh1 nor md5 is provided.

## Output

* `$status` (boolean)   
  Value is "true" if file was downloaded.

## File example

```js
const {$status} = await nikita.file.download({
  source: 'file://path/to/something',
  target: 'node-sigar.tgz'
})
console.info(`File downloaded: ${$status}`)
```

## HTTP example

```js
const {$status} = await nikita.file.download({
  source: 'https://github.com/adaltas/node-nikita/tarball/v0.0.1',
  target: 'node-sigar.tgz'
})
console.info(`File downloaded: ${$status}`)
```

## TODO

It would be nice to support alternatives sources such as FTP(S) or SFTP.
