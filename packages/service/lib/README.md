
# `nikita.service`

Install, start/stop/restart and startup a service.

The config "state" takes 3 possible values: "started", "stopped" and
"restarted". A service will only be restarted if it leads to a change of status.
Set the value to "['started', 'restarted']" to ensure the service will be always
started.

## Output

* `$status`   
  Indicate a change in service such as a change in installation, update,
  start/stop or startup registration.
* `installed`   
  List of installed services.
* `updates`   
  List of services to update.

## Example

```js
const {$status} = await nikita.service([{
  name: 'ganglia-gmetad-3.5.0-99',
  srv_name: 'gmetad',
  state: 'stopped',
  startup: false
},{
  name: 'ganglia-web-3.5.7-99'
}])
console.info(`Service status: ${$status}`)
```
