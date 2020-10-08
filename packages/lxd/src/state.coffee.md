
# `nikita.lxd.state`

Show full device configuration for containers or profiles

## Options

* `container` (string, required)
  The name of the container.
* `device` (string, required)
  Name of the device in LXD configuration, for example "eth0".

## Output parameters

* `err`
  Error object if any.
* `result.status` (boolean)
  True if the device was created or the configuraion updated.
* `result.config` (object)   
  Devince configuration.

## Example

```js
require('nikita')
.lxd.state({
  container: 'container1',
}, function(err, {config}){
  console.log( err ? err.message : config);
  // See below for an output example
})
```

## Source Code

    module.exports = handler: ({options}, callback) ->
      @log message: "Entering lxd.state", level: "DEBUG", module: "@nikitajs/lxd/lib/state"
      #Check args
      valid_devices = ['none', 'nic', 'disk', 'unix-char', 'unix-block', 'usb', 'gpu', 'infiniband', 'proxy']
      # Validation
      throw Error "Invalid Option: container is required" unless options.container
      validate_container_name options.container
      throw Error "Invalid Option: Device name (options.device) is required" unless options.device=
      @system.execute
        cmd: [
          'lxc', 'query',
          [
            '1.0', 'containers', options.container, 'state'
          ].join '/'
        ].join ' '
      , (err, {stdout}) ->
        return callback err if err
        config = JSON.parse stdout
        callback null, config: config

## Dependencies

    validate_container_name = require '../../misc/validate_container_name'

## Output example

```
lxc query /1.0/instances/c1/state
{
 "cpu": {
   "usage": 800378470122
 },
 "disk": {
   "root": {
     "usage": 1113673728
   }
 },
 "memory": {
   "swap_usage": 0,
   "swap_usage_peak": 0,
   "usage": 350429184,
   "usage_peak": 386260992
 },
 "network": {
   "eth0": {
     "addresses": [
       {
         "address": "172.12.0.41",
         "family": "inet",
         "netmask": "24",
         "scope": "global"
       },
       {
         "address": "fe80::206:3eff:fefd:8b89",
         "family": "inet6",
         "netmask": "64",
         "scope": "link"
       }
     ],
     "counters": {
       "bytes_received": 9711064516,
       "bytes_sent": 335003352,
       "packets_received": 5838218,
       "packets_sent": 4172290
     },
     "host_name": "vethe703f52e",
     "hwaddr": "00:16:3e:fc:8c:99",
     "mtu": 1500,
     "state": "up",
     "type": "broadcast"
   },
   "eth1": {
     "addresses": [
       {
         "address": "10.0.0.4",
         "family": "inet",
         "netmask": "24",
         "scope": "global"
       },
       {
         "address": "fe80::206:3eff:fe8b:fb64",
         "family": "inet6",
         "netmask": "64",
         "scope": "link"
       }
     ],
     "counters": {
       "bytes_received": 54675771,
       "bytes_sent": 430441929,
       "packets_received": 316381,
       "packets_sent": 412572
     },
     "host_name": "veth3eea6cae",
     "hwaddr": "00:15:2e:9a:fb:64",
     "mtu": 1500,
     "state": "up",
     "type": "broadcast"
   },
 },
 "pid": 46196,
 "processes": 47,
 "status": "Running",
 "status_code": 103
}
```
