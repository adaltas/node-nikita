
# `nikita.system.group.read`

Read and parse the group definition file located in "/etc/group".

## Output parameters

* `groups`   
  An object where keys are the group names and values are the groups properties.
  See the parameter `group` for a list of available properties.
* `group`
  Properties associated witht the group, only if the input parameter `gid` is
  provided. Available properties are:   
  * `group` (string)   
  Name of the group.
  * `password` (string)   
  Group password as a result of the `crypt` function, rarely used.
  * `gid` (string)   
  The numerical equivalent of the group name. It is used by the operating
  system and applications when determining access privileges.
  * `users` (array[string])   
  List of users who are members of this group.

## Examples

Retrieve all groups informations:

```js
const {groups} = await nikita.system.group.read()
console.info("Available groups:", groups)
```

Retrieve information of an individual group:

```js
const {group} = await nikita.system.group.read({
  gid: 1
})
console.info("The group found:", group)
```
