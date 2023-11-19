
# `nikita.tools.iptables`

Iptables is used to set up, maintain, and inspect the tables of IPv4 packet 
filter rules in the Linux kernel.

Iptables rules are only inserted if the service is started on the target system.

## Output

* `$status`   
  Value is "true" if Iptables rules were created or modified.

## Usage

Iptables comes with many modules. Each of them must be specifically 
integrated to the parser part of this code. For this reason, we could only
integrate a limited set of modules and more are added based on usages. Supported
modules are:

* `state`   
  This module, when combined with connection tracking, allows access to the
  connection tracking state for this packet.   
* `comment`   
  Allows you to add comments (up to 256 characters) to any rule.   
* `limit`   
  Matches at a limited rate using a token bucket filter.   
* `tcp`   
  Used if protocol is set to "tcp", the supported properties are "dport" and
  "sport".   
* `udp`   
  Used if protocol is set to "udp", the supported properties are "dport" and
  "sport".   

## Example

```js
const after = {chain: 'INPUT', jump: 'ACCEPT', 'in-interface': 'lo'}
const {$status} = await nikita.tools.iptables({
  rules: [
    chain: 'INPUT', after: after, jump: 'ACCEPT', dport: 22, protocol: 'tcp'
  ]
})
console.info(`Iptables was updated: ${$status}`)
```

## Command references

List rules in readable format: `iptables -L --line-numbers -nv`
List rules in save format: `iptables -S -v`
