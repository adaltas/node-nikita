
`iptables([goptions], options, callback`
----------------------------------------

Iptables  is  used to set up, maintain, and inspect the tables of IPv4 packet 
filter rules in the Linux kernel.

    each = require 'each'
    misc = require './misc'
    iptables = require './misc/iptables'
    conditions = require './misc/conditions'
    child = require './misc/child'
    execute = require './execute'

### Example

Rule objects may contains the following keys:

*   `rulenum`
*   `protocol`
*   `jump`
*   `in-interface`  Name of an interface via which a packet was received.
*   `out-interface` Name  of an interface via which a packet is going to be sent.
*   `source`        Source  specification.  Address  can  be  either  a network
                    name, a hostname, a network IP address (with /mask), or a
                    plain IP address.
*   `destination`   Destination specification.  See the description of the -s
                    (source) flag for a detailed description of the syntax.   
*   `comment`
*   `state`
*   `dport`         Destination port or port range specification, see the "tcp"
                    and "udp" modules.
*   `sport`         Source  port  or port range specification, see the "tcp" and
                    "udp" modules.

Iptables comes with module functionnalities which must be specifically 
integrated to the code. For this reason, we could only integrate a limited
set of modules and more are added based on usages. Supported modules are:

*   `state`   This module, when combined with connection tracking, allows access
              to the connection tracking state for this packet.
*   `comment` Allows you to add comments (up to 256 characters) to any rule.
*   `tcp`     Used if protocol is set to "tcp", the supported properties are
              "dport" and "sport".
*   `udp`     Used if protocol is set to "udp", the supported properties are
              "dport" and "sport".

```coffee
rulenum = chain: 'INPUT', jump: 'ACCEPT', 'in-interface': 'lo'
mecano.iptables
  ssh: ssh
  rules: [
    chain: 'INPUT', rulenum: rulenum, jump: 'ACCEPT', dport: 22, protocol: 'tcp'
  ]
```

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments
      result = child()
      finish = (err, written) ->
        callback err, written if callback
        result.end err, written
      misc.options options, (err, options) ->
        return callback err if err
        modified = 0
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, next) ->
          options.log? "Mecano `iptables`"
          conditions.all options, next, ->
            options.log? "Mecano `iptables`: list existing rules"
            execute
              cmd: "service iptables status && iptables -S"
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
              code_skipped: 3
            , (err, executed, stdout) ->
              return next err if err
              return next Error "Service iptables not started" unless executed
              oldrules = iptables.parse stdout
              newrules = iptables.normalize options.rules
              cmd = iptables.cmd oldrules, newrules
              return next() unless cmd.length
              options.log? "Mecano `iptables`: modify rules"
              execute
                cmd: "#{cmd.join '; '}; service iptables save"
                ssh: options.ssh
                log: options.log
                trap_on_error: true
                stdout: options.stdout
                stderr: options.stderr
              , (err, executed) ->
                modified++
                next err
        .on 'both', (err) ->
          finish err, modified
      result

## IPTables References

List rules in readable format: `iptables -L --line-numbers -nv`
List rules in save format: `iptables -S -v`


