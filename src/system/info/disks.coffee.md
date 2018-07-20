
# `nikita.system.info.disks(options, [callback])`

Expose disk information. Internally, it parse the result of the "df" command. 
The properties "total", "used" and "available" are expressed in bytes.

## Example

```js
require('nikita')
.system.info.disks(function(err, disks){
  if(err) throw err;
  disks.forEach(function(disk){
    console.log('File system:', disk.filesystem)
    console.log('Total space:', disk.total)
    console.log('Used space:', disk.used)
    console.log('Available space:', disk.available)
    console.log('Available space (pourcent):', disk.available_pourcent)
    console.log('Mountpoint:', disk.mountpoint)
  })
})
```

Here is how the output may look like:

```json
[ { filesystem: '/dev/sda1',
    total: '8255928',
    used: '1683700',
    available: '6152852',
    available_pourcent: '22%',
    mountpoint: '/' },
  { filesystem: 'tmpfs',
    total: '961240',
    used: '0',
    available: '961240',
    available_pourcent: '0%',
    mountpoint: '/dev/shm' } ]
```

## Source Code

    module.exports = (options, callback) ->
      properties = ['filesystem', 'total', 'used', 'available', 'available_pourcent', 'mountpoint']
      @system.execute
        header: 'Disk'
        cmd: 'df'
      , (err, {stdout}) ->
        return callback err if err
        disks = for line, i in string.lines stdout
          continue if i is 0
          continue if /^\s*$/.test line
          line = line.split /\s+/
          disk = {}
          for property, i in properties
            disk[property] = line[i]
          disk.total *= 1024
          disk.used *= 1024
          disk.available *= 1024
          disk
        callback null, disks: disks

## Dependencies

    string = require '../../misc/string'
