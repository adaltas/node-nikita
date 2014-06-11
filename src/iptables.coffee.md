
`iptables([goptions], options, callback`
----------------------------------------

Iptables  is  used to set up, maintain, and inspect the tables of IPv4 packet 
filter rules in the Linux kernel.

    each = require 'each'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'
    execute = require './execute'

### Example

Rule objects may contains the following keys:

*   `rulenum`
*   `protocol`
*   `target`
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
rulenum = chain: 'INPUT', target: 'ACCEPT', 'in-interface': 'lo'
mecano.iptables
  ssh: ssh
  rules: [
    chain: 'INPUT', rulenum: rulenum, target: 'ACCEPT', dport: 22, protocol: 'tcp'
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
        executed = 0
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, next) ->
          crules = []
          cmd = (cmd, rule) ->
            cmd += " -p #{rule.protocol}" if rule.protocol
            cmd += " -s #{rule.source}" if rule.source
            cmd += " -d #{rule.destination}" if rule.destination
            cmd += " -j #{rule.target}" if rule.target
            cmd += " --dport #{rule.dport}" if rule.dport
            cmd += " --sport #{rule.sport}" if rule.sport
            cmd += " -m state --state #{rule.state}" if rule.state
            cmd += " -m comment --comment \"#{rule.comment}\"" if rule.comment
            cmd
          cmd_add = (rule) ->
            cmd "iptables -I #{rule.chain} #{rule.rulenum}", rule
          cmd_modify = (rule) ->
            cmd "iptables -R #{rule.chain} #{rule.rulenum}", rule
          cmd_remove = (rule) ->
            "iptables -D #{rule.chain} #{rule.rulenum}"
          do_list = ->
            chains = {}
            execute
              cmd: "iptables -L --line-numbers -nv"
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, executed, stdout) ->
              return next err if err
              ichain = 0
              chain = null
              for line, i in stdout.split /\r\n|[\n\r\u0085\u2028\u2029]/g
                # Get the chain name
                if ichain is 0
                  match = /^Chain\s+(\w+)\s+.*$/.exec line
                  return next new Error "Invalid output: #{JSON.stringify stdout}" unless match
                  chain = match[1]
                  ichain++
                  continue
                # Skip column headers
                if ichain is 1
                  ichain++
                  continue
                # Detect on of chain definition
                if /^\s*$/.test line
                  ichain = 0
                  continue
                # Parse a rule
                columns = line.split /\ +/
                rule = chain: chain
                for k, i in ['rulenum', 'packets', 'bytes', 'target', 'protocol', 'options', 'in-interface', 'out-interface', 'source', 'destination']
                  rule[k] = columns[i]
                others = columns[10..]
                for v, i in others
                  if v is '/*'
                    rule.comment = ''
                    while (v = others[++i]) isnt '*/'
                      rule.comment += ' '+v
                  else if match = /^dpt:(\d+)$/.exec v
                    rule.dport = match[1]
                  else if v is '--state'
                    rule.state = others[++i]
                crules.push rule
              return next new Error "IPTables rules not loaded, (re)start iptables" if crules.length is 0
              do_position()
          do_position = ->
            for rule in options.rules
              rule.rulenum ?= chain: 'INPUT', target: 'ACCEPT', 'in-interface': 'lo'
              continue unless typeof rule.rulenum is 'object'
              add_properties = misc.array.intersect misc.iptables.add_properties, Object.keys rule.rulenum
              for crule in crules
                if misc.object.equals rule.rulenum, crule, add_properties
                  rule.rulenum = '' + (parseInt(crule.rulenum, 10) + 1)
                  break
              unless /\d+/.test rule.rulenum
                options.log? "No matching rule number, default to 1"
                rule.rulenum = 1
            do_cmds()
          do_cmds = ->
            cmds = []
            for rule in options.rules
              create = true
              add_properties = misc.array.intersect misc.iptables.add_properties, Object.keys rule
              for crule in crules
                if misc.object.equals rule, crule, add_properties
                  create = false
                  if not misc.object.equals rule, crule, misc.iptables.modify_properties
                    cmds.push cmd_modify rule
              if create
                cmds.push cmd_add rule
            return next() unless cmds.length
            execute
              cmd: cmds.join ';'
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, executed, stdout) ->
              return next err if err
              do_save()
          do_save = ->
            execute
              cmd: "service iptables save"
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, executed, stdout) ->
              executed++ unless err
              next err
          conditions.all options, next, do_list
        .on 'both', (err) ->
          finish err, executed
      result