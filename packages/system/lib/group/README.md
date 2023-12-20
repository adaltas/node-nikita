
# `nikita.system.group`

Create or modify a Unix group.

## Callback Parameters
 
* `$status`   
  Value is "true" if group was created or modified.   

## Example

```js
const {$status} = await nikita.system.group({
  name: 'myself'
  system: true
  gid: 490
});
console.info(`Group was created/modified: ${$status}`);
```

The result of the above action can be viewed with the command
`cat /etc/group | grep myself` producing an output similar to
"myself:x:490:".
